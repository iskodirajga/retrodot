RSpec.describe ChatOps::Commands::AddResponderCommand do
  include ChatOpsCommandHelper

  describe 'regex' do
    it_should_match_commands <<-EOL
      add person to incident
      add person and other person to incident
      add person to incident 12
      add person and other person to incident 12
    EOL
  end

  describe '.run' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let!(:incident) { create(:incident, :synced, timeline_start: Time.now) }
    let!(:another_incident) { create(:incident) }

    it "should add a single responder" do
      process "add #{user1.handle} to incident"
      expect(incident.reload.responders).to include user1
    end

    it "should add the responder to the specified incident" do
      process "add #{user1.handle} to incident #{another_incident.incident_id}"
      expect(another_incident.reload.responders).to include user1
    end

    it "should add multiple responders at once by name or handle" do
      process "add @#{user1.handle} and #{user2.name} to incident"
      expect(incident.reload.responders).to include(user1, user2)
    end

    it "should react with a checkmark and no message" do
      expect(process("add @#{user1.handle} to incident")).to react_with(':checkmark:')
    end
  end
end
