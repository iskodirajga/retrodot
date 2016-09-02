module IncidentResponse
  class << self
    # Find any users mentioned in the message and return them.  Users may be
    # mentioned by handle (with or without @ prepended) or by their full name.
    def get_mentioned_users(message)
      ids, message = search_for_names(message)
      handles = search_for_handles(message)

      (User.where(id: ids) + User.where(handle: handles)).uniq
    end

    # Slack doesn't nominally have a way to prevent a mention of a user's
    # handle form triggering highlights.  We intersperse each character of
    # the handle with the unicode character "invisible separator" which has
    # zero width.  The result is visually indistinguishable from their name
    # but doesn't trigger highlights.
    def prevent_highlights(message)
      message.gsub(handles_regex) do |handle|
        unhighlight(handle)
      end
    end

    private
    def normalize_name(name)
      name.downcase.strip.gsub(/\s+/, ' ')
    end

    def search_for_names(message)
      names_to_users = {}

      User.pluck(:name, :id).each do |name, id|
        names_to_users[normalize_name(name)] = id
      end

      # Build an array of regexes, one per name.  We need to match without
      # regard for whitespace, so convert spaces between words into '\s+'.
      names = names_to_users.keys.map do |name|
        name.split.map{|word| Regexp.escape(word)}.join('\s+')
      end

      # Match longer names first.  This makes sure that "John Smith-Jones"
      # doesn't match "John Smith".
      names = names.sort_by {|name| -name.length}

      names_regex = /(?<=^|\W)(#{names.join('|')})(?=$|\W)/i

      mentions = []

      message.gsub! names_regex do |match|
        mentions << names_to_users[normalize_name(match)]

        # Remove the name from the message so that it is not considered for
        # matches on users' handles in search_for_handles.
        " "
      end

      [mentions, message]
    end

    def handles_regex
      handles = User.pluck(:handle)
      /(?<=^|\W)@?(#{Regexp.union(handles)})(?=\W|$)/i
    end

    def search_for_handles(message)
      # Search for people by their handle, with or without @ prepended.

      message.scan(handles_regex).map(&:first).map do |handle|
        handle.downcase
      end
    end

    def unhighlight(handle)
      handle.each_char.to_a.join("\u{2063}")
    end
  end
end
