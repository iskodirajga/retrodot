class ChatopsGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def copy_file
    create_file "lib/chat_ops/commands/#{file_name}_command.rb", <<-FILE
module ChatOps::Commands
  class #{class_name}Command < ChatOps::ChatOpsCommand
    match //
    help_message ""
  end

  def run(user, match)
    # ChatOps.message()
  end
end
    FILE
  end
end
