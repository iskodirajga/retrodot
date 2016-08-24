require 'spec_helper'

describe IncidentsController do

  let(:data) {
    {
      "incident_id": 3227,
      "started_at": "2016-08-03T21:24:21.541Z",
      "resolved_at": "2016-08-03T21:24:23.822Z",
      "contents": "We have received reports of increased failure rates during Postgres provisions. We are investigating the issue.",
      "title": "Issues with Heroku Postgres provisioning",
      "duration": 6000,
      "state": "open",
      "review": true,
      "followup_days": 5
    }
  }

  let(:invalid_data) {
    {
      "incidents": 3124,
      "foo": "bar"
    }
  }


  describe "sync endpoint" do

    before do
      stub_request(:get, Config.source_url).
        with(:headers => {'Host'=>'status.localhost.com:443', 'User-Agent'=>'excon/0.50.1'}).
        to_return(:status => 202, :body => "", :headers => {})
    end

    it 'recieves the post data' do
      allow_any_instance_of(Mediators::Incident::OneSyncher).to receive(:call).and_return(true)

      post :sync, params: data

      expect(response.status).to eq 202
    end

    it 'rejects bad data' do
      allow_any_instance_of(Mediators::Incident::OneSyncher).to receive(:call).and_return(false)

      post :sync, params: invalid_data

      expect(response.status).to eq 500
    end
  end
end
