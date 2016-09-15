module ChatOps::Commands
  class ListResponderCommand < ChatOps::ChatOpsCommand
    match /list\s+incident(\s+(?<incident_id>\d+))?\s+responders/
    help_message "h incident [#] responders - list responders for an incident"

    def run(user, match)
      incident = ChatOps.determine_incident(match['incident_id']) or return ChatOps.unknown_incident

      ChatOps.message("#{incident.responders}")
    end
  end
end
