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

gem "excon", "0.50.1"
gem "configerator"
gem "loggerator", require: [
    "loggerator/rails",
    "loggerator/metrics"
  ]

gem "activeadmin", "~> 1.0.0.pre4"
gem 'inherited_resources', github: 'activeadmin/inherited_resources'
gem 'omniauth-google-oauth2'
gem 'rack-ssl-enforcer'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'rspec-collection_matchers'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'dotenv-rails'
  gem 'pry-nav'
  gem 'pry-rails'
  gem 'webmock', require: 'webmock/rspec'
  gem 'rspec-mocks'
  gem 'database_cleaner'
end

group :development do
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
