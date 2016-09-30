module ChatOps::Commands
  class RemoveResponderCommand < ChatOps::Command
    match /remove\s+(?<who>.*)\s+from\s+incident(\s+(?<incident_id>\d+))?/
    help_message "remove <person> [<person>...] from incident -- <person> can be a full name or @handle"

    def run
      responders = get_mentioned_users(@match['who'])
      return error("Person not found.  Try using their @handle.") if responders.length == 0

      @incident.responders -= responders

      reaction(':checkmark:')
    end
  end
end
