RSpec.describe Incident do
   it { should belong_to(:category) }
   it { should have_many(:retrospectives) }
   it { should have_many(:remediations).through(:retrospectives) }
   it { should have_many(:timeline_entries) }

   describe ".chat_start/end" do
     let(:timestamp) { Time.now.in_time_zone('UTC') }
     let(:incident) { create(:incident, chat_start: timestamp, chat_end: timestamp) }
     let(:incident_from_db) { Incident.find_by(id: incident.id) }
     let(:time_zone) { 'US/Pacific' }

     before(:each) do
       allow(Config).to receive(:time_zone).and_return(time_zone)
     end

     it "returns the correct timestamp" do
       # Gotta use inexact comparison because the timestamp loses precision when
       # round-tripped through the DB.  All we care is that it represents the
       # same point in time, irrespective of time zone.
       expect(incident_from_db.chat_start).to match_to_the_millisecond timestamp
       expect(incident_from_db.chat_end).to match_to_the_millisecond timestamp
     end

     it "returns the timestamp in the configured time zone" do
       expect(incident_from_db.chat_start.time_zone).to eq ActiveSupport::TimeZone[time_zone]
       expect(incident_from_db.chat_end.time_zone).to eq ActiveSupport::TimeZone[time_zone]
     end
   end
end
