module ChatOps
  @@commands = []

  class << self

    # Subclasses of ChatOps::Command register themselves here when they are
    # declared.  @@commands ends up as an array of all subclasses of
    # ChatOpsCommand.
    def register(klass)
      @@commands << klass
    end

    def commands
      @@commands
    end

    # Generates a regex that matches any of the declared ChatOps::Command
    # subclassess.  We massage the regex a bit so that it's more palatable to
    # regex implementations with fewer features than Ruby's.
    def matcher
      "(?ix)" + commands.map(&:regex).map(&:source).join('|').gsub(/\(\?<[^>]+>/, '(')
    end

    # Get a help message describing each command.
    def help
      commands.map(&:help).reject(&:blank?).join("\n")
    end

    # Try to process a message as a ChatOps command.  Return nil if no
    # command matched.  TODO: define return value for success.
    def process(user, message)
      commands.each do |command|
        if result = command.new.process(user, message)
          return result
        end
      end

      nil
    end

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

    def message(text)
      { message: prevent_highlights(text) }
    end

    # In the future, this might tag with some kind of metadata indicating an
    # error.
    alias_method :error, :message

    def reaction(name)
      { reaction: name }
    end

    private
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
      names_to_users = User.with_name.pluck(:name, :id).each_with_object({}) do |(name, id), h|
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

# Load all .rb files in the 'commands' subdirectory using the require_all gem.
# Rails's autoloading won't automatically load the subclasses, so without this
# ChatOps.commands would return an empty array.
require_rel 'commands'
