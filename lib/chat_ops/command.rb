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
          incident = ChatOps.determine_incident(result[:incident_id]) or return ChatOps.unknown_incident
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

    private

    # LIBRARY FUNCTIONS
    #
    # These utility functions are used by chatops commands.


    # Find any users mentioned in the message and return them.  Users may be
    # mentioned by handle (with or without @ prepended) or by their full name.
    def get_mentioned_users(message)
      ids = find_and_remove_names!(message)
      handles = find_handles(message)

      (User.where(id: ids) + User.where(handle: handles)).uniq
    end

    # Slack doesn't nominally have a way to prevent a mention of a user's
    # handle from triggering highlights.  We intersperse each character of
    # the handle with the unicode character "invisible separator" which has
    # zero width.  The result is visually indistinguishable from their name
    # but doesn't trigger highlights.
    def prevent_highlights(message)
      message.gsub(handles_regex) do |handle|
        unhighlight(handle)
      end
    end

    # Parse a timestamp specified in natural language.
    def parse_timestamp(timestamp)
      Time.use_zone(Config.time_zone) do
        Chronic.time_class = Time.zone

        # Chronic likes "today at 3pm" but not "at 3pm".
        timestamp.sub! /^at /, ''

        result = Chronic.parse(timestamp)

        # The presence of a time zone causes Chronic to return nil in all but a
        # few select formats.  https://github.com/mojombo/chronic/issues/134
        # Work around that bug by stripping off the time zone, parsing, then
        # pasting it back on and parsing again.
        if !result
          timestamp.sub! /\s+(\S+)$/, ''
          tz = fix_dst($1.upcase)

          return unless result = Chronic.parse(timestamp)

          result = Chronic.parse(result.strftime("%F %T #{tz}"))
        end

        return result
      end
    end

    def current_incident
      Incident.by_timeline_start.first
    end

    def determine_incident(id)
      if id
        Incident.find_by(incident_id: id)
      else
        current_incident
      end
    end

    def unknown_incident
      message 'unknown incident (do you need to "start incident" first?)'
    end

    def old_incident_warning(incident)
      ChatOps.message "It looks like you may have forgotten to run `#{Config.chatops_prefix}start incident`.  If you really meant incident #{incident.incident_id}, please specify the incident id with your command."
    end

    def message(text)
      { message: prevent_highlights(text) }
    end

    # In the future, this might tag with some kind of metadata indicating an
    # error.
    alias_method :error, :message

    def reaction(name)
      { reaction: name }
    end

    # If passed "EST" during daylight time, return "EDT", and the reverse.
    # People often say "3pm EST" when it's technically "3pm EDT" during that
    # part of the year.
    def fix_dst(tz)
      tz = tz.dup

      case tz
      when /DT$/i
        # All *DT time zones match up with the corresponding -ST time zone.  For
        # Example, EDT -> EST
        tz.sub! /DT$/i, 'ST' if !in_dst?
      when /[PMCE]ST$/i
        # NOT all *ST time zones match up with a corresponding -DT time zone.
        # For example, CEST -> CET.
        tz.sub! /ST$/i, 'DT' if in_dst?
      end

      tz
    end

    def in_dst?
      Time.use_zone(Config.time_zone) { Time.zone.now.isdst }
    end

    def normalize_name(name)
      name.downcase.strip.gsub(/\s+/, ' ')
    end

    def find_and_remove_names!(message)
      names_to_users = User.pluck(:name, :id).each_with_object({}) do |(name, id), h|
        h[normalize_name(name)] = id
      end

      # Build an array of regexes, one per name.  We should match a name even if
      # the number of spaces is different, so convert spaces between words into
      # '\s+'.
      names = names_to_users.keys.map do |name|
        name.split.map{|word| Regexp.escape(word)}.join('\s+')
      end

      # Match longer names first.  This makes sure that "John Smith-Jones"
      # doesn't match "John Smith".
      names = names.sort_by(&:length).reverse

      names.reject!(&:nil?)
      names.reject!(&:empty?)

      names_regex = /(?<=^|[^a-zA-Z0-9_@])(#{names.join('|')})(?=$|\W)/i

      message.gsub!(names_regex).each_with_object([]) do |match, users|
        users << names_to_users[normalize_name(match)]

        # Remove the name from the message so that it is not considered for
        # matches on users' handles in search_for_handles.
        " "
      end
    end

    def handles_regex
      handles = User.with_handle.pluck(:handle)
      /(?<=^|\W)@?(#{handles.join('|')})(?=\W|$)/i
    end

    # Search for people by their handle, with or without @ prepended.
    def find_handles(message)

      message.scan(handles_regex).map(&:first).map do |handle|
        handle.downcase
      end
    end

    def unhighlight(handle)
      handle.each_char.to_a.join("\u{2063}")
    end
  end
end
