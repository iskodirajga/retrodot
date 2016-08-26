class ChatOpsCommand
  class << self
    alias :commands :subclasses
  end
end

# Load all commands using require_all gem
require_rel 'commands'
