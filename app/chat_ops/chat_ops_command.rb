class ChatOpsCommand
  class << self
    def inherited(klass)
      ChatOps.register(klass)
    end

    def regex(r = nil)
      @regex = r if r
      @regex
    end
  end
end
