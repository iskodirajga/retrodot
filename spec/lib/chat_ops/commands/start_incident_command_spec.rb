RSpec.describe ChatOps::Commands::StartIncidentCommand do
  include ChatOpsCommandHelper

  describe "regex" do
    test_regex_against_commands <<-EOL
      start incident
      start an incident
      start incident 900
      start an incident at 09:30
      start an incident 5 minutes ago
      start incident 300 5 minutes ago
    EOL
  end

  describe ".run" do
    command :start_incident

    def last_incident
      Incident.by_timeline_start.first
    end

    def last_incident_id
      last_incident.incident_id
    end
    it "picks incident id 1 if no incidents exist" do
      start_incident
      expect(last_incident_id).to eq 1
    end

    it "picks the latest open incident if one exists" do
      create(:incident, :synced, incident_id: 1)
      create(:incident, :synced, open: true, incident_id: 2)

      start_incident

      expect(last_incident_id).to eq 2
    end

    it "picks the next available incident id if no incident is open" do
      create(:incident, :synced, incident_id: 1)
      create(:incident, :synced, incident_id: 2)

      start_incident

      expect(last_incident_id).to eq 3
    end

    it "only considers synced incidents" do
      create(:incident, :synced, incident_id: 1)
      create(:incident, incident_id: 2)

      start_incident

      expect(last_incident_id).to eq 2
    end

    it "sets chat start to the current time when no time is specified" do
      Timecop.freeze do
        start_incident
        expect(last_incident.chat_start).to be_within(0.001).of Time.now
      end
    end

    it "overwrites chat start when run a second time" do
      Timecop.freeze 10.minutes.ago do
        start_incident
      end

      first_incident_id = last_incident_id

      Timecop.freeze do
        start_incident

        expect(last_incident.chat_start).to be_within(0.001).of Time.now
      end

      expect(last_incident_id).to eq first_incident_id
    end

    it "uses the timestamp provided" do
      Timecop.freeze do
        start_incident "ten minutes ago"
        expect(last_incident.chat_start).to be_within(0.001).of 10.minutes.ago
      end
    end

    it "allows the user to specify the incident id" do
      start_incident "14"
      expect(last_incident_id).to eq 14
    end

    it "properly handles 'start an incident 14 minutes ago'" do
      Timecop.freeze do
        start_incident "14 minutes ago"
        expect(last_incident_id).not_to eq 14
        expect(last_incident.chat_start).to be_within(0.001).of 14.minutes.ago
      end
    end
  end
end
