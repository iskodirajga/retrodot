module ChatOps::Commands
  class RemoveResponderCommand < ChatOps::ChatOpsCommand
    match /remove\s+(?<who>.*)\s+from\s+incident(\s+(?<incident_id>\d+))?/
    help_message "h remove <person> [<person>...] from incident -- <person> can be a full name or @handle"
  end

  def run(user, match)
    incident = ChatOps.determine_incident(match['incident_id']) or return ChatOps.unknown_incident

    responders = ChatOps.get_mentioned_users(match['who'])
    return ChatOps.error("Person not found.  Try using their @handle.") if responders.length == 0

    incident.responders -= responders

    ChatOps.reaction(':checkmark:')
  end
end
