module ChatOps
  class Command
    class << self
      attr_reader :regex, :help

      # Ruby calls this function when a class is declared that inherits from this
      # class.  We then register it with the ChatOps module.
      def inherited(klass)
        ChatOps.register(klass)
      end

      def incident_optional?
        @incident_optional == true
      end

      # Outsiders should call the process() class method instead.
      private :new
      def process(user, message)
        new(user, message).process
      end

      private
      def match(r)
        @regex = r
      end

      def help_message(text)
        @help = [Config.chatops_prefix, text].compact.join(' ')
      end

      # By default, process() tries to parse the incident_id capture group as
      # an incident, and complains if the incident doesn't exist.  If
      # the class has incident_optional in its declaration, then the complaint
      # is suppressed.
      def incident_optional
        @incident_optional = true
      end
    end

    def initialize(user, message)
      @user = user
      @message = message
    end

    def process
      if result = self.class.regex.match(@message)
        @match = result

        if @match.names.include? "incident_id"
          @incident = determine_incident(result[:incident_id])

          if !self.class.incident_optional?
            return unknown_incident_warning if !@incident
            return old_incident_warning if result[:incident_id].nil? and @incident.old?
          end
        end

        run
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
    def run
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
