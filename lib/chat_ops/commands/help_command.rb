module ChatOps::Commands
  class HelpCommand < ChatOps::Command
    setup do
      match /^help$/
    end

    def run
      message(ChatOps.help)
    end
  end
end
