require 'spec_helper'

RSpec.describe Api::V1::ChatOpsController do
  render_views

  describe "GET #matcher" do
    it "returns 403 for requests without API token" do
      get :matcher
      expect(response).to have_http_status(:unauthorized)
    end

    it "calls ChatOps.matcher" do
      allow(Config).to receive(:chatops_api_key).and_return("sekrit")
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
      allow(Config).to receive(:chatops_api_key).and_return("sekrit")
      expect(ChatOps).to receive(:process).exactly(1).times
      basic_auth "api", Config.chatops_api_key
      post :respond, params: {user: {email: "test", handle: "test", name: "test"}}

      # 404 because no command matches our (blank) message
      expect(response).to have_http_status(:not_found)
    end
  end
end
