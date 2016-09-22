module ChatOps::Commands
  class StartIncidentCommand < ChatOps::Command
    match %r{
            # allow "start incident" or "start an incident"
            start\s+(an\s+)?incident
            (\s+
              (
                # if they specify an incident ID, use that.
                (?<incident_id>\d+)

                # incident ID must be followed by whitespace or EOL
                (\s+|$)

                # Don't match incident #14 in "start an incident 14 minutes ago"
                (?!(seconds|minutes|hours)\s+ago)

              )?

              # Slurp up the remainder.  ChatOps.parse_timestamp will
              # parse it as a timestamp specified in natural language.
              (?<timestamp>.*)
            )?
            $
          }ix

    help_message "h start incident [#] [at <timespec>] - sets or overwrites incident start time (timespec examples: 5 minutes ago, 3pm, etc)"

    def run(user, match)
      incident_id = infer_incident_id(match[:incident_id])
      chat_start = get_chat_start(match[:timestamp]).in_time_zone(Config.time_zone)

      message = ["Recorded the start of chat for incident \##{incident_id} at #{chat_start.inspect}"]

      incident = Incident.find_or_create_by(incident_id: incident_id)

      if incident.chat_start
        message << "     (overwriting start time for incident \##{incident_id}, was: #{incident.chat_start.inspect})"
      end

      incident.timeline_start = Time.now
      incident.chat_start = get_chat_start(match[:timestamp])
      incident.responders << user
      incident.save

      ChatOps.help.each_line do |line|
        message << "  " + line
      end

      ChatOps.message(message.join("\n"))
    end

    private
    def infer_incident_id(incident_id=nil)
      # If they specified an incident ID, use it.
      # Otherwise, if an incident is open, they probably mean that one.
      incident_id = Incident.open.first&.incident_id if !incident_id

      incident_id ||= if !Incident.synced.empty?
                        # If no incident is open, they probably mean the ID of the next incident to
                        # be opened.
                        Incident.synced.first.incident_id + 1
                      else
                        # But if no incidents have been opened yet, just default to 1.
                        1
                      end

      incident_id
    end

    def get_chat_start(timestamp=nil)
      if !timestamp.blank?
        ::ChatOps.parse_timestamp(timestamp)
      end || Time.now
    end
  end
end
