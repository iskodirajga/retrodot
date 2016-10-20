RSpec::Matchers.define :return_response_matching do |expected|
  match do |actual|
    actual && actual[:message] =~ expected
  end
end

RSpec::Matchers.define :react_with do |expected|
  match do |actual|
    actual && actual[:reaction] == expected
  end
end

RSpec::Matchers.define :not_have_message do |expected=nil|
  match do |actual|
    !actual.has_key?(:message)
  end
end

module ChatOpsCommandHelper
  def self.included(base)
    base.extend ContextMethods
    base.include ExampleMethods
  end

  module ExampleMethods
    def process(command, user=nil)
      described_class.process(user || create(:user), command)
    end

    def set_current_incident(incident)
      allow_any_instance_of(described_class).to receive(:current_incident).and_return(incident)
    end
  end

  module ContextMethods
    def command(cmd)
      define_method(cmd) do |arg=""|
        process("#{cmd.to_s.sub('_', ' ')} #{arg}")
      end
    end

    def it_should_match_commands(commands)
      _generate_match_tests commands do |command|
        it { is_expected.to match command }
      end
    end

    def it_should_not_match_commands(commands)
      _generate_match_tests commands do |command|
        it { is_expected.not_to match command }
      end
    end

    def _generate_match_tests(commands)
      subject { described_class.regex }

      commands.each_line.map(&:strip).each do |command|
        yield command
      end
    end
  end
end
