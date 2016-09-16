module ChatOps
  class ChatOpsCommand
    class << self
      attr_reader :regex, :name, :help

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
        @help = text
      end
    end

    def process(user, message)
      if result = self.class.regex.match(message)
        if should_parse_incident
          incident = ChatOps.determine_incident(result[:incident_id]) or return ChatOps.unknown_incident
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
    #
    # If the run method takes an `incident` parameter, then it is a command that
    # allows the user to optionally pass an incident ID.  The regex should have
    # a named capture group like (?<incident_id>\d+)?.  If the user passed an
    # incident ID, it will be looked up and the incident object will be passed
    # into run().  Otherwise the current incident is looked up and passed in
    # (see ChatOps.current_incident).

    def run(user, match_data)
      raise NotImplementedError
    end

    private
    # If the run method takes a parameter named `incident`, then this is a
    # command that optionally allows the incident to be passed in.
    def should_parse_incident
      run = method :run
      run.parameters.any? do |type, name|
        name == :incident
      end
    end
  end
end
