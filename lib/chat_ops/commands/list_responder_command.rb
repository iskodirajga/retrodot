module ChatOps::Commands
  class ListResponderCommand < ChatOps::Command
    setup do
      match /incident(\s+(?<incident_id>\d+))?\s+responders/
      help "`incident [#] responders` - list responders for an incident"
    end

    def run
      message("Incident responders for incident #{@incident.incident_id}: #{@incident.responders.map(&:name).join(", ")}")
    end
  end
end
