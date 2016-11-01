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
    # subclassess.  This regex can be given to external systems to filter for
    # messages Retrodot cares about.

    def matcher
      # We massage the regex a bit so that it's more palatable to regex
      # implementations with fewer features than Ruby's, for example JavaScript.
      Regexp.new("(?ix)" + commands.map(&:regex).map(&:source).join('|').gsub(/\(\?<[^>]+>/, '('))
    end

    # Get a help message describing each command.
    def help
      help = commands.map(&:help).reject(&:blank?).join("\n")
      { message: help }
    end

    # Try to process a message as a ChatOps command.  Return nil if no
    # command matched.  TODO: define return value for success.
    def process(user, message)
      return help if message == "help"

      commands.each do |command|
        if result = command.process(user, message)
          return result
        end
      end

      nil
    end
  end
end

# Load all .rb files in the 'commands' subdirectory using the require_all gem.
# Rails's autoloading won't automatically load the subclasses, so without this
# ChatOps.commands would return an empty array.
require_rel 'commands'
