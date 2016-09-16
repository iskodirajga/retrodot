class ChatopsGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def copy_file
    create_file "lib/chat_ops/commands/#{file_name}_command.rb", <<-FILE
module ChatOps::Commands
  class #{class_name}Command < ChatOps::ChatOpsCommand
    match //
    help_message ""

    def run(user, match)
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
    it it_should_match_commands <<-EOL
      # some command
    EOL
  end

  describe '.run' do
    it "tests some thing" do
    end
  end
end
    FILE
  end
end
