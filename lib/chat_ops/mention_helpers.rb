module ChatOps
  module MentionHelpers
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

    private
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

    def normalize_name(name)
      name.downcase.strip.gsub(/\s+/, ' ')
    end
  end
end
