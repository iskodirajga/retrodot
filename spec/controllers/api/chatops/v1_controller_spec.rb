require 'spec_helper'

RSpec.describe Api::Chatops::V1Controller, type: :controller do
  render_views

  describe "GET #matcher" do
    it "returns 403 for requests without API token" do
      get :matcher
      expect(response).to have_http_status(:forbidden)
    end

    it "calls ChatOps.matcher" do
      expect(ChatOps).to receive(:matcher).exactly(1).times
      get :matcher, params: {API_KEY: Config.chatops_api_key}
    end
  end

  describe "GET #respond" do
    it "returns 403 for requests without API token" do
      get :respond
      expect(response).to have_http_status(:forbidden)
    end

    it "calls ChatOps.process" do
      expect(ChatOps).to receive(:process).exactly(1).times
      get :respond, params: {API_KEY: Config.chatops_api_key}
    end
  end

end
