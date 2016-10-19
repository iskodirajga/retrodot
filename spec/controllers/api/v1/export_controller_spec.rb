require 'rails_helper'

RSpec.describe Api::V1::ExportController, type: :controller do

  describe "GET #csv" do
    it "returns http success" do
      get :csv
      expect(response).to have_http_status(:success)
    end
  end

end
