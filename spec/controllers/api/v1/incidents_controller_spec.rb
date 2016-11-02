RSpec.describe Api::V1::IncidentsController do
  let(:invalid_data) {{"incidents": 3124, "foo": "bar"}}
  let!(:data)        {{"incident_id": 3227, "update_type"=>"issue"}}
  let!(:user)        { create(:user, :slack_access_token) }

  before do
    stub_request(:get, Config.source_url).to_return(status: 202)
    stub_request(:post, "https://slack.com/api/chat.postMessage").to_return(status: 200)
    allow_any_instance_of(Mediators::Incident::OneSyncher).to receive(:call).and_return(true)
  end

  describe "Existing incidents" do
    let!(:incident) { create(:incident, incident_id: 3227)}

    it "starts an incident" do
      expect_any_instance_of(ChatOps::Commands::StartIncidentCommand).to receive(:process).and_return({message: "foo"})

      post :sync, params: data

      expect(response).to have_http_status(:accepted)
    end

    it "sends a message" do
      expect(ChatOps::Commands::StartIncidentCommand).to receive(:process).and_return({message: "foo"})
      expect_any_instance_of(Slack::Client).to receive(:chat_postMessage).
        with({:channel=>"retrodot", :username=>"retrodot", :text=>"foo"})

      post :sync, params: data

      expect(response).to have_http_status(:accepted)
    end

    describe "Existing incidents with a timeline" do
      let!(:timeline) { create(:timeline_entry, incident: incident, user: user)}

      it "does not start incident" do
        expect_any_instance_of(ChatOps::Commands::StartIncidentCommand).to_not receive(:process)

        post :sync, params: data

        expect(response).to have_http_status(:forbidden)
      end

      it "does not post to slack" do
        expect_any_instance_of(Slack::Client).to_not receive(:chat_postMessage)
        expect_any_instance_of(ChatOps::Commands::StartIncidentCommand).to_not receive(:process)

        post :sync, params: data

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "Missing incidents" do
    it "Syncs missing incidents" do
      expect(Mediators::Incident::OneSyncher).to receive(:run).with(id: "3227")

      post :sync, params: data

      expect(response).to have_http_status(:accepted)
    end

    it "starts an incident" do
      post :sync, params: data

      expect(response).to have_http_status(:accepted)
    end

    it "does not start for scheduled /maintenance updates" do
      data["update_type"] = "scheduled"
      post :sync, params: data
      expect(response).to have_http_status(:forbidden)

      data["update_type"] = "maintenance"
      post :sync, params: data

      expect(response).to have_http_status(:forbidden)
    end
  end
end
