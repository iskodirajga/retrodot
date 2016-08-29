require 'spec_helper'

# Can't do `Rspec.describe ChatOps` here or the require_rel will get run before
# we stub it below.
RSpec.describe ChatOps do
  # This can't be a let because of weird ruby scoping stuff.
  REGEX1 = /test_regex1_[0-9]+/
  TESTSTRING1 = "test_regex1_0923"

  REGEX2 = /test_regex2_[a-z]+/
  TESTSTRING2 = "test_regex2_aklsdf"

  RESULT = "Command1.run"

  before do
    class TestCommand1 < ChatOpsCommand
      match REGEX1
    end

    class TestCommand2 < ChatOpsCommand
      match REGEX2


      def run(user, result)
        RESULT
      end
    end
  end

  it "adds commands to the list" do
    expect(ChatOps.commands).to include TestCommand1, TestCommand2
  end

  it "builds a regex from defined commands" do
    expect(ChatOps.matcher).to match TESTSTRING1
    expect(ChatOps.matcher).to match TESTSTRING2
  end

  it "calls process on an instance of each defined command" do
    expect_any_instance_of(TestCommand1).to receive(:process).exactly(1).times.and_call_original
    expect_any_instance_of(TestCommand2).to receive(:process).exactly(1).times.and_call_original

    ChatOps.process("user", "message")
  end

  it "calls run only on the command that matched" do
    expect_any_instance_of(TestCommand1).not_to receive(:run)
    expect_any_instance_of(TestCommand2).to receive(:run).exactly(1).times.and_call_original

    expect(ChatOps.process("user", TESTSTRING2)).to eq RESULT
  end
end
