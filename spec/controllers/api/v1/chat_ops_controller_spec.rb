require 'spec_helper'

RSpec.describe Api::V1::ChatOpsController do
  render_views

  describe "GET #matcher" do
    it "returns 403 for requests without API token" do
      get :matcher
      expect(response).to have_http_status(:unauthorized)
    end

    it "calls ChatOps.matcher" do
      expect(ChatOps).to receive(:matcher).exactly(1).times
      basic_auth "api", Config.chatops_api_key
      get :matcher
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #respond" do
    it "returns 403 for requests without API token" do
      post :respond
      expect(response).to have_http_status(:unauthorized)
    end

    it "calls ChatOps.process" do
      expect(ChatOps).to receive(:process).exactly(1).times
      basic_auth "api", Config.chatops_api_key
      post :respond, params: {user: {email: "test", handle: "test", name: "test"}, message: :foo}

      # 404 because no command matches our (blank) message
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#Message" do
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

    it "processes a message" do
      expect(ChatOps).to receive(:process)

      post :slack_slash_command, params: data

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("text", "response_type")
    end

    it "renders errors with invalid tokens" do
      allow(Config).to receive(:slack_slash_command_token).and_return("XXXXXXX")
      post :slack_slash_command, params: data

      expect(response).to have_http_status(:unauthorized)
    end

    it "renders errors for missing users" do
      data[:user_id] = "INVALID"
      post :slack_slash_command, params: data

      expect(response).to have_http_status(:forbidden)
    end

  end
end
