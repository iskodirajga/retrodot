require 'spec_helper'

# Can't do `Rspec.describe ChatOps` here or the require_rel will get run before
# we stub it below.
RSpec.describe 'ChatOps' do
  before(:each) do
    # Prevent commands from app/chat_ops/commands from being loaded.
    Object.any_instance.stub(:require_rel)
  end

  describe "registration" do
    # This can't be a let because of weird ruby scoping stuff.
    REGEX1 = /regex1/
    REGEX2 = /regex2/

    RESULT = "Command1.run"

    before do
      class Command1 < ChatOpsCommand
        match REGEX1
      end

      class Command2 < ChatOpsCommand
        match REGEX2


        def run(user, result)
          RESULT
        end
      end
    end

    it "adds commands to the list" do
      expect(ChatOps.commands).to eq [Command1, Command2]
    end

    it "builds a regex from defined commands" do
      expect(ChatOps.matcher).to eq Regexp.union(REGEX1, REGEX2)
    end

    it "calls process on an instance of each defined command" do
      expect_any_instance_of(Command1).to receive(:process).exactly(1).times.and_call_original
      expect_any_instance_of(Command2).to receive(:process).exactly(1).times.and_call_original

      ChatOps.process("user", "message")
    end

    it "calls run only on the command that matched" do
      expect_any_instance_of(Command1).not_to receive(:run)
      expect_any_instance_of(Command2).to receive(:run).exactly(1).times.and_call_original

      expect(ChatOps.process("user", REGEX2.source)).to eq RESULT
    end
  end
end
