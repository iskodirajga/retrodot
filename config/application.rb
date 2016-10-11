require_relative 'boot'
require 'rails/all'
require_relative 'config'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Retrodot
  class Application < Rails::Application
    config.autoload_paths   += %W( #{config.root}/lib )
    config.autoload_paths   += %W( #{config.root}/lib/chat_ops )

    # Eager loading works differently in production so we have to
    # load chatops to load rails properly
    config.eager_load_paths += %W( #{config.root}/lib/chat_ops )
  end
end
