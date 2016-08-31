describe Mediators::Incident::MultiSyncher do
  let!(:url) { "https://example.localhost.com" }

  def encoded_data
    MultiJson.encode(incident_details)
  end

  def incident_details
    [
      {
        "incident_id"=>1,
        "title"=>"Routing issues",
        "state"=>"resolved",
        "started_at"=>"2016-06-02T12:09:37.154Z",
        "updated_at"=>"2016-06-10T20:48:54.483Z",
        "resolved"=>true,
        "duration"=>1016,
        "resolved_at"=>"2016-06-02T12:26:33.061Z",
        "review"=>true,
      },
      {
        "incident_id"=>2,
        "title"=>"API issues",
        "state"=>"resolved",
        "started_at"=>"2016-07-02T12:09:37.154Z",
        "updated_at"=>"2016-07-10T20:48:54.483Z",
        "resolved"=>true,
        "duration"=>1016,
        "resolved_at"=>"2016-07-02T12:26:33.061Z",
        "review"=>true,
      }
    ]
  end

  describe "#call" do
    before do
      stub_request(:get, "#{url}/?page=1&per_page=100").to_return(
        body: encoded_data,
        headers: {"Link" => "<#{url}?page=1&per_page=100>; rel=\"last\", <#{url}?page=1&per_page=100>; rel=\"next\""}
      )
    end

    it 'Syncs multiple incidents' do
      allow(Config).to receive(:source_url).and_return(url)

      assert_equal 0, Incident.all.count
      Mediators::Incident::MultiSyncher.run

      assert_equal 2, Incident.all.count
    end

    it 'updates multiple incidents with outdated information' do
      allow(Config).to receive(:source_url).and_return(url)

      Mediators::Incident::MultiSyncher.run

      incident1 = Incident.where(incident_id: 1).first
      incident1.update_attribute(:state, "open")
      incident2 = Incident.where(incident_id: 2).first
      incident2.update_attribute(:state, "open")

      assert_equal "open", incident1.state
      assert_equal "open", incident1.state

      Mediators::Incident::MultiSyncher.run

      incident1.reload
      incident2.reload

      assert_equal "resolved", incident1.state
      assert_equal "resolved", incident2.state
    end
  end
end
