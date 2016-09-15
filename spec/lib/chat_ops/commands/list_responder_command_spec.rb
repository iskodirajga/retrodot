RSpec.describe ChatOps::Commands::ListResponderCommand do
  include ChatOpsCommandHelper

  describe 'regex' do
    test_regex_against_commands <<-EOL
      list incident responders
      list incident 13 responders
    EOL
  end

  describe '.run' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let!(:incident) { create(:incident, :synced, timeline_start: Time.now) }

    it "should list a single responder" do
      process "add #{user1.handle} to incident"
      expect(process("list incident responder")).to return_response_matching /something/
    end
  end
end
