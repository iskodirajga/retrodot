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
        @help = Config.chatops_prefix + text
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
          incident = ChatOps.determine_incident(result[:incident_id]) or return ChatOps.unknown_incident
          return old_incident(incident) if result[:incident_id].nil? and is_old_incident?(incident)
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

    private
    # If they don't specify an incident ID and it's been awhile since there
    # was any activity on an incident, it probably means they forgot to do
    # `start incident`.  We'll try to detect that here.
    def is_old_incident?(incident)
      # they specifically told us via chatops that they were done, so they
      # probably don't mean this one
      return true if incident.chat_end

      # the incident is still open in the external incident source, so they
      # probably mean this one
      return false if incident.open?

      return true if !incident.timeline_entries.empty? && incident.timeline_entries.last.timestamp < 1.hour.ago

      return true if incident.timeline_entries.empty? && incident.chat_start? && incident.chat_start < 1.hour.ago

      false
    end

    def old_incident(incident)
      ChatOps.message "It looks like you may have forgotten to run `#{Config.chatops_prefix}start incident`.  If you really meant incident #{incident.incident_id}, please specify the incident id with your command."
    end
  end
end
