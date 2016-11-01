module ChatOps::Commands
  class EndIncidentCommand < ChatOps::Command
    setup do
      match /end\s+(the\s+)?incident(\s+(?<incident_id>[0-9]+))?/
      help "`end incident [#]` - sets the end of chat for an incident"
    end

    def run
      @incident.chat_end = Time.now
      @incident.save

      return { message: "Recorded the end of chat for incident #{@incident.incident_id} at #{@incident.chat_end.inspect}." }
    end
  end
end
