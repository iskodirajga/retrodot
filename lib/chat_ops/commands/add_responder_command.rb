module ChatOps::Commands
  class AddResponderCommand < ChatOps::Command
    setup do
      match /add\s+(?<who>.*)\s+to\s+incident(\s+(?<incident_id>\d+))?/
      help "add <person> [<person>...] to incident -- <person> can be a full name or @handle"
    end

    def run
      responders = get_mentioned_users(@match['who'])
      return error("Person not found.  Try using their @handle.") if responders.length == 0

      @incident.responders += responders

      reaction(':checkmark:')
    end
  end
end
