source 'https://rubygems.org'

ruby '2.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0'

gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem "haml-rails", "~> 0.9"
gem "chronic"

gem "excon", "0.50.1"
gem "configerator"
gem "loggerator", require: [
    "loggerator/rails",
    "loggerator/metrics"
  ]

gem "activeadmin", "~> 1.0.0.pre4"
gem 'inherited_resources', git: 'https://github.com/activeadmin/inherited_resources'
gem 'omniauth-google-oauth2'
gem 'rack-ssl-enforcer'
gem 'require_all'
gem 'active_record_ignored_attributes'
gem 'omniauth-trello'
gem 'ruby-trello', "~> 1.5.1"
gem 'default_value_for', '~> 3.0.0'
gem 'google-api-client', '~> 0.9.15'
gem 'googleauth'
gem 'slack-api'

# The upstream maintained version doesn't support signin with slack.
gem 'omniauth-slack', git: 'https://github.com/joshuatobin/omniauth-slack', branch: 'signin-with-slack-support'

group :development, :test do
  gem 'rspec-collection_matchers'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'dotenv-rails'
  gem 'pry-nav'
  gem 'pry-rails'
  gem 'rspec-mocks'
  gem 'database_cleaner'
  gem 'pry-remote'
  gem 'pry-byebug', '~> 1.3.3'
end

group :test do
  gem 'webmock'
  gem 'timecop'
end

group :development do
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
