describe Mediators::Incident::OneSyncher do
  let(:id) { '900' }

  def encoded_data
    MultiJson.encode(incident_details)
  end

  def incident_details
    {
      "incident_id"=>900,
      "title"=>"Routing issues",
      "state"=>"resolved",
      "started_at"=>"2016-06-02T12:09:37.154Z",
      "updated_at"=>"2016-06-10T20:48:54.483Z",
      "resolved"=>true,
      "duration"=>1016,
      "resolved_at"=>"2016-06-02T12:26:33.061Z",
      "review"=>true,
    }
  end

  describe "#call" do
     before do
       stub_request(:get, "#{Config.source_url}/#{id}").to_return(body: encoded_data)
     end

     it 'Syncs an incident' do
       Mediators::Incident::OneSyncher.run(id: id)

       assert_equal 1, Incident.where(incident_id: id).count
     end

     it 'updates an incident with outdated information' do
       Mediators::Incident::OneSyncher.run(id: id)

       incident = Incident.where(incident_id: id).first
       incident.update_attribute(:state, "open")

       assert_equal "open", incident.state

       Mediators::Incident::OneSyncher.run(id: id)
       incident.reload

       assert_equal "resolved", incident.state
     end
   end
end
