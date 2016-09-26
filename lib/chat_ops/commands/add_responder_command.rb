module ChatOps::Commands
  class AddResponderCommand < ChatOps::Command
    match /add\s+(?<who>.*)\s+to\s+incident(\s+(?<incident_id>\d+))?/
    parse_incident true
    help_message "add <person> [<person>...] to incident -- <person> can be a full name or @handle"

    def run(user, match, incident)
      responders = ChatOps.get_mentioned_users(match['who'])
      return ChatOps.error("Person not found.  Try using their @handle.") if responders.length == 0

      incident.responders += responders

      ChatOps.reaction(':checkmark:')
    end
  end
end
