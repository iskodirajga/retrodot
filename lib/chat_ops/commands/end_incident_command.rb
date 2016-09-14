module ChatOps::Commands
  class EndIncidentCommand < ChatOps::ChatOpsCommand
    match /end\s+(the\s+)?incident(\s+(?<incident_id>[0-9]+))?/
    help_message "end incident [#] - sets the end of chat for an incident"

    def run(user, match)
      incident = if match['incident_id']
        Incident.find_by(incident_id: match['incident_id'])
      else
        IncidentResponse::current_incident()
      end
      return { message: 'unknown incident (do you need to "start incident" first?)' } unless incident

      incident.chat_end = Time.nowq
      incident.save

      return { message: "Recorded the end of chat for incident #\#{incident.incident_id} at #{incident.chat_end.inspect}." }
    end
  end
end
