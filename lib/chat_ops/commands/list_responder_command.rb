module ChatOps::Commands
  class ListResponderCommand < ChatOps::Command
    match /incident(\s+(?<incident_id>\d+))?\s+responders/
    help_message "incident [#] responders - list responders for an incident"

    def run
      message("Incident responders for incident #{@incident.incident_id}: #{@incident.responders.map(&:name).join(", ")}")
    end
  end
end
