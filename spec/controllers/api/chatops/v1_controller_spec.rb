require 'rails_helper'

RSpec.describe Api::Chatops::V1Controller, type: :controller do

  describe "GET #matcher" do
    it "returns http success" do
      get :matcher
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #respond" do
    it "returns http success" do
      get :respond
      expect(response).to have_http_status(:success)
    end
  end

end
