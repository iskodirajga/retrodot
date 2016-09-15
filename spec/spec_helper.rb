ENV["RAILS_ENV"] ||= 'test'
ENV["HOSTNAME"] = 'retrodot.test'

require 'dotenv'
Dotenv.load!('.env.test')

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'loggerator/test'
require 'helpers/chat_ops_command_helper'
require 'helpers/time_helper'

# Checks for pending migrations before tests are run.
ActiveRecord::Migration.maintain_test_schema! if defined?(ActiveRecord::Migration)

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include AuthHelper, type: :controller

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.infer_spec_type_from_file_location!

  config.include Rails.application.routes.url_helpers
  config.include FactoryGirl::Syntax::Methods

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
    mocks.syntax = [:expect, :should]
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.disable_monkey_patching!

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, rgemove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
