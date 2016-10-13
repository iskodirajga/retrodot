module ChatOps::Commands
  class TimelineCommand < ChatOps::Command
    setup do
      match /timeline(\s+(?<incident_id>\d+))?$/
      help "timeline [#] - list the timeline for a incident"
    end

    def run
      message(prevent_highlights("Timeline for incident #{@incident.incident_id}\n#{@incident.format_timeline}"))
    end
  end
end
