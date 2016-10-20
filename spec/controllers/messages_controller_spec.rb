RSpec.describe MessagesController do
  let!(:user) { create(:user, slack_user_id: "U00001") }

  let!(:data) {
    {
      "token": "123456789",
      "user_id": "U00001",
      "team_domain": "domain.com",
      "channel_name": "retrodot",
      "user_name": "retrodots",
      "command": "/timeline",
      "text": "start an incident",
      "response_url": "https://hooks.slack.com/commands/T00001/xxxxx"
    }
  }

  before do
    allow(Config).to receive(:slack_slash_command_token).and_return("123456789")
  end


  describe "#Create" do
    it "processes a message" do
      expect(ChatOps).to receive(:process)

      post :create, params: data

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("text", "response_type")
    end

    it "renders errors with invalid tokens" do
      allow(Config).to receive(:slack_slash_command_token).and_return("XXXXXXX")
      post :create, params: data

      expect(response).to have_http_status(:unauthorized)
    end

    it "renders errors for missing users" do
      data[:user_id] = "INVALID"
      post :create, params: data

      expect(response).to have_http_status(:forbidden)
    end

  end
end
