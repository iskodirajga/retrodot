module ChatOps
  @@commands = []

  class << self
    def register(klass)
      @@commands << klass
    end

    def commands
      @@commands
    end

    def matcher
      Regexp.union(commands.collect{|command| command.regex})
    end
  end
end

# Load all commands using require_all gem
require_rel 'commands'
