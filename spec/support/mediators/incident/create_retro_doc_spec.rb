RSpec.describe Mediators::Incident::CreateRetroDoc do
  let!(:incident)   { create(:incident) }
  let!(:user)       { create(:user, :trello_oauth) }
  let!(:trello_url) { "https://trello.com/c/AbCdEfG" }

  let(:resp) {
    {
      :name=>"create_retro_doc",
      :done=>true,
      :response=>
          {
            :@type=>"type.googleapis.com/google.apps.script.v1.ExecutionResponse",
            :result=> "https://docs.google.com/a/domain.com/open?id=f-LZ1gAZjar0"
          }
     }
  }

  describe "#call" do
    before do
      @auth    = instance_double("auth")
      @service = instance_double("service", authorization: @auth)

      allow(Google::Apis::ScriptV1::ScriptService).to receive(:new).and_return(@service)
      allow(@service).to receive(:run_script).and_return(resp)
    end

    it 'Creates a Doc ' do
      expect(Mediators::Incident::CreateRetroDoc).to receive(:run).and_return(resp)

      Mediators::Incident::CreateRetroDoc.run(
        auth:       @auth,
        id:         incident.id,
        title:      incident.title,
        trello_url: trello_url
      )
    end
  end
end
