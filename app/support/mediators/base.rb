require "loggerator/rails"
require "loggerator/metrics"

module Mediators
  class Base

    def self.run(options={})
      new(options).call
    end

    def initialize(options={})
      @options = options
    end
  end
end
