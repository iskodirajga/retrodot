RSpec.describe ChatOps::Commands::TimelineCommand do
  include ChatOpsCommandHelper

  describe 'regex' do
    it_should_match_commands <<-EOL
      timeline
      timeline 13
    EOL

    it_should_not_match_commands <<-EOL
      timeline 13 some thing
    EOL
  end

  describe '.run' do
    let!(:now)             { Time.now }
    let!(:user1)           { create(:user) }
    let!(:incident1)       { create(:incident, :synced, timeline_start: now) }
    let!(:timeline_entry1) { create(:timeline_entry, timestamp: now, incident: incident1, user: user1)}

    let!(:past)            { Time.now - 1.day}
    let!(:user2)           { create(:user) }
    let!(:incident2)       { create(:incident, :synced, timeline_start: past, incident_id: 7) }
    let!(:timeline_entry2) { create(:timeline_entry, timestamp: past, incident: incident2, user: user2)}

    let!(:user3)           { create(:user) }
    let!(:timeline_entry3) { create(:timeline_entry, timestamp: past, incident: incident2, user: user3)}

    it "lists current incidents timeline" do
      Timecop.freeze(now) do
        expect(process("timeline")).to return_response_matching /Timeline for incident #{incident1.incident_id}\n#{timeline_entry1.timestamp.utc} #{ChatOps.prevent_highlights(user1.name)}: #{timeline_entry1.message}/
      end
    end

    it "lists a past incidents timeline" do
      expect(process("timeline 7")).to return_response_matching /Timeline for incident 7\n#{timeline_entry2.timestamp.utc} #{ChatOps.prevent_highlights(user2.name)}: #{timeline_entry2.message}/
    end

    it "lists multiple timeline entries" do
      expect(process("timeline 7")).to return_response_matching(/#{ChatOps.prevent_highlights(user2.name)}/, /#{ChatOps.prevent_highlights(user3.name)}/)
    end
  end
end
