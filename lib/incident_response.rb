module IncidentResponse
  class << self
    # Find any users mentioned in the message and return them.  Users may be
    # mentioned by handle (with or without @ prepended) or by their full name.
    def get_mentioned_users(message)
      words = split_words(message)
      users, words = search_for_names(words)
      users += search_for_handles(words)
      users.uniq
    end

    # Slack doesn't nominally have a way to prevent a mention of a user's
    # handle form triggering highlights.  We intersperse each character of
    # the handle with the unicode character "invisible separator" which has
    # zero width.  The result is visually indistinguishable from their name
    # but doesn't trigger highlights.
    def prevent_highlights(message)
      message.gsub(WORD_RE) do |word|
        if search_for_handles(word).length > 0
          unhighlight(word)
        else
          word
        end
      end
    end

    private
    WORD_RE = /[\w']+/

    def split_words(message)
      message.scan(/[\w']+/).map(&:downcase)
    end

    def get_users_by_name
      Hash[User.all.collect{|user| [split_words(user.name), user]}]
    end

    def search_for_names(words)
      # Look for full names in the message.  Names must be at least 2 words
      # long and up to Config.max_words_in_name words long.  If we find a full
      # name, we should remove the words in question to avoid double-counting
      # the word(s) as a shorter name or a handle.
      #
      # For example, let's say we have three distinct people:
      #   * John Jones (@john)
      #   * John Smith (@jsmith)
      #   * John Smith-Jones (@jsj)
      #
      # and this message:
      #
      #   "Soon John Smith-Jones will deploy the fix."
      #
      # words will look like this:
      #
      # [ "soon", "john", "smith", "jones", "will", "deploy", "the", "fix" ]
      #
      # Config.max_words_in_name is set to 3.
      #
      # We should start checking at each word in turn, and look for 3-word names
      # then 2-word names.  We'll see ["john", "smith", "jones"] and know that
      # John Smith-Jones was mentioned.  We remove words 2-4 from the list to
      # avoid mistakenly thinking that "John Smith" was mentioned.  We also
      # avoid returning word 2 so that search_for_handles does not think @john
      # was mentioned.

      leftovers = []
      users = []
      users_by_name = get_users_by_name
      skip_words = 0

      #binding.pry

      0.upto(words.length - 1) do |i|
        if skip_words > 0
          skip_words -= 1
          next
        end

        Config.max_words_in_name.downto(2).detect do |length|
          if user = (users_by_name[words[i,length]] || users_by_name[strip_contraction(words[i,length])])
            skip_words = length - 1
            users << user
          end
        end || (leftovers << words[i])
      end

      [users, leftovers]
    end

    def strip_contraction(word_or_words)
      if word_or_words.is_a? Array
        word_or_words[-1] = strip_contraction(word_or_words[-1])
        word_or_words
      else
        word_or_words.sub(/'[^']+$/, '')
      end
    end

    def search_for_handles(words)
      # Search for people by their handle, with or without @ prepended.

      Array(words).collect do |word|
        word.sub! /^@/, ''
        User.find_by(handle: [word, strip_contraction(word)].uniq)
      end.reject &:nil?
    end

    def unhighlight(handle)
      handle.each_char.to_a.join("\u{2063}")
    end
  end
end
