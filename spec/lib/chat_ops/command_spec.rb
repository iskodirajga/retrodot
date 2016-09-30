RSpec.describe ChatOps::Command do
  let(:command_class) { Class.new(ChatOps::Command) }
  let(:command) { command_class.new }
  let(:foo_incident_regex) { /foo(\s+(?<incident_id>\d+))?/ }
  let(:foo_regex) { /foo/ }
  let(:forgot_message) { /it looks like you may have forgotten/i }
  let(:test_help_message) { "hello world" }
  let(:user) { create(:user) }
  let(:test_incident) { create(:incident) }
  let(:incident_with_chat_end) { create(:incident, timeline_start: 1.day.ago, chat_end: Time.now) }
  let(:incident_with_old_timeline) { create(:incident, timeline_start: 1.day.ago, timeline_entries: [{timestamp: 1.day.ago}]) }
  let(:incident_with_old_chat_start) { create(:incident, timeline_start: 1.day.ago, chat_start: 1.day.ago) }
  let(:recent_incident) { create(:incident, timeline_start: 1.hour.ago, chat_start: 1.hour.ago, timeline_entries: [{timestamp: 1.minute.ago}]) }
  let(:open_incident) { create(:incident, state: "open", timeline_start: 1.hour.ago) }


  # Helper method to set up a Command subclass with match regex, parse_incident,
  # and an optional definition of the `run` method by passing a block.
  def setup_command(match: nil, parse_incident: false, help_message: nil)
    command_class.class_exec(match,
                             parse_incident,
                             help_message,
                             block_given? ? Proc.new : nil) do |regex, should_parse, help_text, block|
      match regex if regex
      parse_incident should_parse
      help_message help_text if help_text

      if block
        define_method(:run, &block)
      end
    end
  end

  def process(message)
    command.process(user, message)
  end

  describe '.match' do
    it 'stores the regex' do
      setup_command(match: foo_regex)
      expect(command_class.regex).to eq foo_regex
    end
  end

  describe '.help_message' do
    it 'stores the help message' do
      setup_command(help_message: test_help_message)
      expect(command_class.help).to eq test_help_message
    end

    it 'prepends the chatops prefix' do
      allow(Config).to receive(:chatops_prefix).and_return("h")
      setup_command(help_message: test_help_message)
      expect(command_class.help).to eq "h #{test_help_message}"
    end
  end

  describe '.parse_incident' do
    it 'stores the should_parse_incident flag' do
      setup_command(parse_incident: true)
      expect(command_class.should_parse_incident).to eq true
    end
  end

  describe '.process' do
    it "returns nil if the message doesn't match the regex" do
      setup_command(match: foo_regex)
      expect(command).not_to receive(:run)
      expect(process("bar")).to eq nil
    end

    it "calls run if the message matches the regex" do
      setup_command(match: foo_regex)
      expect(command).to receive(:run).and_return(true)
      expect(process("foo")).to eq true
    end

    it "parses an incident ID if requested to" do
      setup_command(match: foo_incident_regex, parse_incident: true) do |user, match, incident|
        # return the incident so we can do expects on it
        incident
      end

      expect(command).to receive(:run).and_call_original
      incident = process("foo #{test_incident.incident_id}")

      expect(incident).to be_same_as(test_incident)
    end

    it "doesn't parse an incident ID if not requested to" do
      setup_command(match: foo_incident_regex)

      # Failure of this test would be if Command.process tried to pass an
      # incident as the third parameter to run(), which would raise an
      # exception.
      expect(command).to receive(:run)
      expect(process("foo #{test_incident.incident_id}")).to eq nil
    end

    it "returns an error if told to parse an incident and passed an invalid incident ID" do
      setup_command(match: foo_incident_regex, parse_incident: true)

      expect(command).not_to receive(:run)
      expect(process("foo 123")).to return_response_matching /unknown incident/
    end

    it "suggests the user run 'start incident' if last incident has a chat_end" do
      setup_command(match: foo_incident_regex, parse_incident: true)

      incident_with_chat_end

      expect(command).not_to receive(:run)
      expect(process("foo")).to return_response_matching forgot_message
    end

    it "suggests the user run 'start incident' if timeline was not updated recently" do
      setup_command(match: foo_incident_regex, parse_incident: true)

      incident_with_chat_end

      expect(command).not_to receive(:run)
      expect(process("foo")).to return_response_matching forgot_message
    end

    it "suggests the user run 'start incident' if last incident has no timeline entries and chat_start is old" do
      setup_command(match: foo_incident_regex, parse_incident: true)

      incident_with_old_chat_start

      expect(command).not_to receive(:run)
      expect(process("foo")).to return_response_matching forgot_message
    end

    it "allows the user to override old incident detection" do
      setup_command(match: foo_incident_regex, parse_incident: true) do |user, match, incident|
        message("hello world")
      end

      expect(command).to receive(:run).and_call_original
      expect(process("foo #{incident_with_old_chat_start.incident_id}")).not_to return_response_matching forgot_message
    end

    it "does not treat a recent incident as old" do
      setup_command(match: foo_incident_regex, parse_incident: true) do |user, match, incident|
        message("hello world")
      end

      recent_incident

      expect(command).to receive(:run).and_call_original
      expect(process("foo")).not_to return_response_matching forgot_message
    end

    it "does not treat an open incident as old" do
      setup_command(match: foo_incident_regex, parse_incident: true) do |user, match, incident|
        message("hello world")
      end

      open_incident

      expect(command).to receive(:run).and_call_original
      expect(process("foo")).not_to return_response_matching forgot_message
    end
  end
end
