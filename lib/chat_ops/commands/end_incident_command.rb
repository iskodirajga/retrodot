module ChatOps::Commands
  class EndIncidentCommand < ChatOps::Command
    match /end\s+(the\s+)?incident(\s+(?<incident_id>[0-9]+))?/
    parse_incident true
    help_message "end incident [#] - sets the end of chat for an incident"

    def run(user, match, incident)
      incident.chat_end = Time.now
      incident.save

      return { message: "Recorded the end of chat for incident #\#{incident.incident_id} at #{incident.chat_end.inspect}." }
    end
  end
end
