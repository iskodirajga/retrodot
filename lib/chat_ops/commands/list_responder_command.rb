module ChatOps::Commands
  class ListResponderCommand < ChatOps::Command
    match /incident(\s+(?<incident_id>\d+))?\s+responders/
    parse_incident true
    help_message "h incident [#] responders - list responders for an incident"

    def run(user, match, incident)
      ChatOps.message("Incident responders for incident #{incident.incident_id}: #{incident.responders.map(&:name).join(", ")}")
    end
  end
end
