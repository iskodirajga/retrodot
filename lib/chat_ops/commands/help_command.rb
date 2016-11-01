module ChatOps::Commands
  class ListResponderCommand < ChatOps::Command
    setup do
      match /^help$/
    end

    def run
      message(ChatOps.help)
    end
  end
end
