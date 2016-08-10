require_relative 'boot'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Retrodot
  class Application < Rails::Application

    # We have to require dotenv before configerator is loaded
    Dotenv::Railtie.load

    require_relative 'config'
  end
end
