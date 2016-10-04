module ChatOps::Commands
  class TimelineCommand < ChatOps::Command
    match /timeline(\s+(?<incident_id>\d+))?/
    help_message "timeline [#] - list the timeline for a incident"
    parse_incident true

    def run(user, match, incident)
      ChatOps.message("Timeline for incident #{incident.incident_id}\n#{incident.format_timeline}")
    end
  end
end
