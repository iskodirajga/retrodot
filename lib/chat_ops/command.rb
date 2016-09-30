module ChatOps
  class Command
    class << self
      attr_reader :regex, :name, :help, :should_parse_incident

      # Ruby calls this function when a class is declared that inherits from this
      # class.  We then register it with the ChatOps module.
      def inherited(klass)
        ChatOps.register(klass)
      end

      private
      def match(r)
        @regex = r
      end

      def help_message(text)
        @help = [Config.chatops_prefix, text].compact.join(' ')
      end

      # If this is set to true, then this command can take an optional incident
      # ID.  Its regex should have a (?<incident_id>\d+)? group.  process() will
      # retrieve the specified incident from the DB and pass it in as an
      # argument to run().  If the user does not specify an incident, then
      # ChatOps.current_incident is used.
      def parse_incident(should_parse_incident)
        @should_parse_incident = should_parse_incident
      end
    end

    def process(user, message)
      if result = self.class.regex.match(message)
        if self.class.should_parse_incident
          incident = determine_incident(result[:incident_id]) or return unknown_incident_warning
          return old_incident_warning(incident) if result[:incident_id].nil? and incident.old?
          run(user, result, incident)
        else
          run(user, result)
        end
      end
    end

    # Implement run() in the subclass.  It should return a hash describing the
    # response.  The hash may contain the following keys:
    #
    #   message: (optional) text to reply back with
    #   subject: (optional) a subject line for an extended message, e.g. Slack's
    #     "attachments"
    #   reaction: (optional) name of an emoji to add as a reaction to the user's
    #     message
    #
    # Return nil to indicate that we don't actually want to process the command
    # after all.
    def run(user, match_data)
      raise NotImplementedError
    end

    # LIBRARY FUNCTIONS
    #
    # These utility functions are used by chatops commands.

    include ChatOps::MentionHelpers
    include ChatOps::TimeStampHelpers
    include ChatOps::MessageHelpers
    include ChatOps::IncidentHelpers
  end
end
