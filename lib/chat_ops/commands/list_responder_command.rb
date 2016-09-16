module ChatOps::Commands
  class ListResponderCommand < ChatOps::ChatOpsCommand
    match /incident(\s+(?<incident_id>\d+))?\s+responders/
    help_message "h incident [#] responders - list responders for an incident"

    def run(user, match)
      incident = ChatOps.determine_incident(match['incident_id']) or return ChatOps.unknown_incident

      ChatOps.message("Incident responders for incident #{incident.id}: #{incident.responders.map(&:name).join(",")}")
    end
  end
end
