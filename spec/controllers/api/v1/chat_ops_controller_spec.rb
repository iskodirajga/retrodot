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
      post :responder
      expect(response).to have_http_status(:unauthorized)
    end

    it "calls ChatOps.process" do
      expect(ChatOps).to receive(:process).exactly(1).times
      basic_auth "api", Config.chatops_api_key
      post :responder, params: {user: {email: "test", handle: "test", name: "test"}, message: :foo}

      # 404 because no command matches our (blank) message
      expect(response).to have_http_status(:not_found)
    end
  end
end
