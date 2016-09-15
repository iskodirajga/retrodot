RSpec::Matchers.define :return_response_matching do |expected|
  match do |actual|
    actual[:message] =~ expected
  end
end

module ChatOpsCommandHelper
  def self.included(base)
    base.extend ContextMethods
    base.include ExampleMethods
  end

  module ExampleMethods
    def process(command, user=nil)
      described_class.new.process(user || create(:user), command)
    end
  end

  module ContextMethods
    def test_regex_against_commands(commands)
      subject { described_class.regex }

      commands.each_line.map(&:strip).each do |command|
        it { is_expected.to match command }
      end
    end

    def command(cmd)
      define_method(cmd) do |arg=""|
        process("#{cmd.to_s.sub('_', ' ')} #{arg}")
      end
    end
  end
end
