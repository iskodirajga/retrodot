RSpec.describe ChatOps::Command do
  let(:command_class) { Class.new(ChatOps::Command) }
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
  def setup_command(match: nil, incident_optional: false, help_message: nil, run_should_not_be_called: false)
    command_class.class_exec(match,
                             incident_optional,
                             help_message,
                             run_should_not_be_called,
                             block_given? ? Proc.new : nil) \
    do |regex, optional, help_text, run_should_not_be_called, block|
      setup do
        match regex if regex

        # bizarre ruby edge-case: if I don't use parens here, ruby assumes I mean
        # the incident_optional argument to setup_command()
        incident_optional() if optional

        help help_text if help_text
      end

      if run_should_not_be_called
        def run
          raise Exception.new("run() should not be called in this test")
        end
      elsif block
        define_method(:run, &block)
      end
    end
  end

  def process(message)
    command_class.process(user, message)
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

  describe '.incident_optional' do
    it 'stores the incident_optional? flag' do
      setup_command(incident_optional: true)
      expect(command_class.incident_optional?).to eq true
    end
  end

  describe '.process' do
    it "returns nil if the message doesn't match the regex" do
      setup_command(match: foo_regex, run_should_not_be_called: true)
      expect(process("bar")).to eq nil
    end

    it "calls run if the message matches the regex" do
      setup_command(match: foo_regex) { true }
      expect(process("foo")).to eq true
    end

    it "parses an incident ID if requested to" do
      setup_command(match: foo_incident_regex) do
        # return the incident so we can do expects on it
        @incident
      end

      incident = process("foo #{test_incident.incident_id}")

      expect(incident).to be_same_as(test_incident)
    end

    it "returns an error if passed an invalid incident ID" do
      setup_command(match: foo_incident_regex, run_should_not_be_called: true)

      expect(process("foo 123")).to return_response_matching /unknown incident/
    end

    it "does not return an error if passed an invalid incident id if told that incident is optional" do
      setup_command(match: foo_incident_regex, incident_optional: true)

      expect_any_instance_of(command_class).to receive(:run)
      expect(process("foo 123")).not_to return_response_matching /unknown incident/
    end

    it "suggests the user run 'start incident' if last incident has a chat_end" do
      setup_command(match: foo_incident_regex, run_should_not_be_called: true)

      incident_with_chat_end

      expect(process("foo")).to return_response_matching forgot_message
    end

    it "suggests the user run 'start incident' if timeline was not updated recently" do
      setup_command(match: foo_incident_regex, run_should_not_be_called: true)

      incident_with_chat_end

      expect(process("foo")).to return_response_matching forgot_message
    end

    it "suggests the user run 'start incident' if last incident has no timeline entries and chat_start is old" do
      setup_command(match: foo_incident_regex, run_should_not_be_called: true)

      incident_with_old_chat_start

      expect(process("foo")).to return_response_matching forgot_message
    end

    it "allows the user to override old incident detection" do
      setup_command(match: foo_incident_regex) do
        message("hello world")
      end

      expect_any_instance_of(command_class).to receive(:run).and_call_original
      expect(process("foo #{incident_with_old_chat_start.incident_id}")).not_to return_response_matching forgot_message
    end

    it "does not treat a recent incident as old" do
      setup_command(match: foo_incident_regex) do
        message("hello world")
      end

      recent_incident

      expect_any_instance_of(command_class).to receive(:run).and_call_original
      expect(process("foo")).not_to return_response_matching forgot_message
    end

    it "does not treat an open incident as old" do
      setup_command(match: foo_incident_regex) do
        message("hello world")
      end

      open_incident

      expect_any_instance_of(command_class).to receive(:run).and_call_original
      expect(process("foo")).not_to return_response_matching forgot_message
    end
  end
end
