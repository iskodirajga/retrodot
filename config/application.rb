require_relative 'boot'
require 'rails/all'
require_relative 'config'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Retrodot
  class Application < Rails::Application
#    config.autoload_paths << Rails.root.join('lib')
#    config.autoload_paths << Rails.root.join('lib', 'chat_ops')
    #config.eager_load_paths << Rails.root.join('lib', 'chat_ops')
    #config.paths.add "lib/chat_ops", eager_load: true
    config.eager_load_paths.unshift("#{config.root}/lib/chat_ops")
    #config.eager_load_paths += %W( #{config.root}/lib/chat_ops )
  end
end
