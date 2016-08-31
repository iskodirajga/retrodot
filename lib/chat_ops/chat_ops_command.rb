class ChatOpsCommand
  class << self
    attr_reader :regex, :name

    # Ruby calls this function when a class is declared that inherits from this
    # class.  We then register it with the ChatOps module.
    def inherited(klass)
      ChatOps.register(klass)
    end

    private
    def match(r)
      @regex = r
    end

    def name(n)
      @name = n
    end
  end

  def process(user, message)
    if result = self.class.regex.match(message)
      run(user, result)
    end
  end

  def run(user, message)
    # define in subclass
    {"error": "command not implemented"}
  end
end
