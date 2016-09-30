RSpec.describe ChatOps::IncidentHelpers do
  let(:helper) { Class.new { extend ChatOps::IncidentHelpers } }\

  describe '.current_incident' do
    it "returns nil if no incidents have non-nil timeline_start" do
      create(:incident)
      expect(helper.current_incident).to eq nil
    end

    it "returns the incident with the most recent timeline_start" do
      create(:incident, incident_id: 1, timeline_start: 5.minutes.ago)
      create(:incident, incident_id: 2, timeline_start: 10.minutes.ago)
      expect(helper.current_incident.incident_id).to eq 1
    end
  end
end
