RSpec.describe ChatOps::Commands::RemoveResponderCommand do
  include ChatOpsCommandHelper

  describe 'regex' do
    test_regex_against_commands <<-EOL
      remove person from incident
      remove person and other person from incident
      remove person from incident 12
      remove person and other person from incident 12
    EOL
  end

  describe '.run' do
    let(:user1)             { create(:user) }
    let(:user2)             { create(:user) }
    let!(:incident)         { create(:incident_with_responder, users: [user1, user2]) }
    let!(:another_incident) { create(:incident_with_responder, users: [user2, user1]) }

    it "should remove a single responder" do
      binding.pry
      process "remove #{user1.handle} from incident"
      expect(incident.reload.responders).not_to include user1
    end

    it "should remove the responder to the specified incident" do
      process "remove #{user1.handle} from incident #{another_incident.incident_id}"
      expect(another_incident.reload.responders).not_to include user1
    end

    it "should remove multiple responders at once by name or handle" do
      process "remove @#{user1.handle} and #{user2.name} from incident"
      expect(incident.reload.responders).not_to include(user1, user2)
    end

    it "should react with a checkmark and no message" do
      #expect(process("remove @#{user1.handle} from incident")).to react_with(':checkmark:').and not_have_message
    end
  end
end
