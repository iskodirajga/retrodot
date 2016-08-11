require_relative 'boot'
require 'rails/all'
require_relative 'config'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Retrodot
  class Application < Rails::Application

  end
end
