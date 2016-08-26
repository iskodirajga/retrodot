module ChatOps
  @@commands = []

  class << self

    # Subclasses of ChatOpsCommand register themselves here when they are
    # declared.  @@commands ends up as an array of all subclasses of
    # ChatOpsCommand.
    def register(klass)
      @@commands << klass
    end

    def commands
      @@commands
    end

    # Generates a regex that matches any of the declared ChatOpsCommands.
    # Each ChatOpsCommand has its own regex, so we use Regexp.union to
    # combine them.  It's almost the same as joining them with '|'.
    def matcher
      Regexp.union(commands.collect{|command| command.regex})
    end
  end
end

# Load all .rb files in the 'commands' subdirectory using the require_all gem.
# Rails's autoloading won't automatically load the subclasses, so without this
# ChatOpsCommands.commands would return an empty array.
require_rel 'commands'
