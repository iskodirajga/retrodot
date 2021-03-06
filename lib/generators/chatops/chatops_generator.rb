class ChatopsGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def copy_file
    create_file "lib/chat_ops/commands/#{file_name}_command.rb", <<-FILE
module ChatOps::Commands
  class #{class_name}Command < ChatOps::Command
    match //
    help_message ""

    # A command can request that an optional incident ID be parsed
    # automatically by setting this to true.  Add (?<incident_id>\d+)? in the
    # match regex above and the incident will be looked up and passed in to
    # run().
    parse_incident false

    def run(user, match, incident=nil)
      # ChatOps.message()
    end
  end
end
    FILE
  end

  def copy_spec
    create_file "spec/lib/chat_ops/commands/#{file_name}_command_spec.rb", <<-FILE
RSpec.describe ChatOps::Commands::#{class_name}Command do
  include ChatOpsCommandHelper

  describe 'regex' do
    it_should_match_commands <<-EOL
      # some command
      # some other command
    EOL
  end

  describe '.run' do
    it "tests some thing" do
      # expect(process("add @\#{user1.handle} to incident")).to react_with(':checkmark:').and not_have_message
    end
  end
end
    FILE
  end
end
