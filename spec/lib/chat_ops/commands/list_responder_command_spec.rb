RSpec.describe ChatOps::Commands::ListResponderCommand do
  include ChatOpsCommandHelper

  describe 'regex' do
    test_regex_against_commands <<-EOL
      incident responders
      incident 13 responders
    EOL
  end

  describe '.run' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let!(:incident) { create(:incident, :synced, timeline_start: Time.now) }

    it "should list a single responder" do
      incident.responders << user1
      incident.save

      expect(process("incident responders")).to return_response_matching /#{user1.handle}/
    end

    it "should list multiple responders" do
      incident.responders << user1
      incident.responders << user2
      incident.save

      expect(process("incident responders")).to return_response_matching(/#{user1.handle}/).and return_response_matching(/#{user2.handle}/).and return_response_matching /#{incident.id}/
    end
  end
end
