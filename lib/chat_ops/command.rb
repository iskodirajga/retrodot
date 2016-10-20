module ChatOps
  class CommandSetup
    attr_reader :config

    def initialize
      @config = {}
    end

    def match(m)
      @config[:regex] = m
    end

    def help(h)
      @config[:help] = h
    end

    def incident_optional(value=true)
      @config[:incident_optional] = value
    end
  end

  class Command
    class << self
      attr_reader :regex

      # Ruby calls this function when a class is declared that inherits from this
      # class.  We then register it with the ChatOps module.
      def inherited(klass)
        ChatOps.register(klass)
      end

      def process(user, message)
        new(user, message).process
      end

      # Outsiders should call process() instead.
      private :new

      def incident_optional?
        @incident_optional
      end

      def help
        [Config.chatops_prefix, @help].compact.join(' ')
      end

      private
      def setup(&block)
        s = CommandSetup.new
        s.instance_eval &block
        s.config.each do |name, value|
          instance_variable_set "@#{name}", value
        end
      end
    end

    def initialize(user, message)
      @user = user
      @message = message
    end

    def process
      return unless @match = self.class.regex.match(@message)

      if @match.names.include? "incident_id"
        @incident = determine_incident(@match[:incident_id])

        if !self.class.incident_optional?
          return unknown_incident_warning if !@incident
          return old_incident_warning if @match[:incident_id].nil? and @incident.old?
        end
      end

      run
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
