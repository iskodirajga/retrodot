module ChatOps
  module TimeStampHelpers
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
  end
end
