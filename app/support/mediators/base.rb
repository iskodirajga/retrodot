
module Mediators
  class Base
    include Loggerator

    def self.run(options={})
      log_context(mediator: self.name) do
        log action: "call"
        result = new(options).call
        log action: "end"
        result
      end
    end

    def initialize(options={})
      @options = options
    end
  end
end
