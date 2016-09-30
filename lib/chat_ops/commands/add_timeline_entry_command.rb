module ChatOps::Commands
  class AddTimelineEntryCommand < ChatOps::Command
    # This regex is a little tricky.  We want to match these:
    #
    #   timeline hello world
    #   timeline 20 hello world
    #
    # but not this:
    #
    #   timeline 20
    #
    # because the latter is a request to list the timeline for incident 20 and
    # is handled by ListTimelineCommand.
    match %r{
              timeline
              \s+
              (
                # If they specify an id...
                (?<incident_id>\d+)

                \s+

                # ...then only match if they also specify a message
                (?<message>.+)

              |

                # Otherwise, only match if it's not just a number.
                (?!\d+$)

                (?<message>.*)
              )
            }ix
    parse_incident true
    help_message "timeline [#] <message> - adds a message to the timeline for the specified incident (or the current incident if no ID is specified)"

    def run(user, match, incident)
      get_mentioned_users(match[:message]).each do |responder|
        incident.responders << responder
      end

      # Add the user who is running this command, because they're probably
      # involved too.
      incident.responders << user

      incident.timeline_entries << ::TimelineEntry.new(user: user, message: match[:message])

      reaction(':checkmark:')
    end
  end
end
