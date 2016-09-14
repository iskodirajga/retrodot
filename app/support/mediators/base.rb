
module Mediators
  class Base
    include Loggerator

    def self.run(options={})
      new(options).call
    end

    def initialize(options={})
      @options = options
    end
  end
end
