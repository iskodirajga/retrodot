module ChatOps::Commands
  class RemoveResponderCommand < ChatOps::Command
    match /remove\s+(?<who>.*)\s+from\s+incident(\s+(?<incident_id>\d+))?/
    parse_incident true
    help_message "h remove <person> [<person>...] from incident -- <person> can be a full name or @handle"

    def run(user, match, incident)
      responders = ChatOps.get_mentioned_users(match['who'])
      return ChatOps.error("Person not found.  Try using their @handle.") if responders.length == 0

      incident.responders -= responders

      ChatOps.reaction(':checkmark:')
    end
  end
end
