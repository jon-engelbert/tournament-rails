source 'https://rubygems.org'
#specify ruby version for Heroku
ruby "2.2.0"
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>= 4.2.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
gem 'bootstrap-sass'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'
# gem 'jquery-turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'
gem 'faker',                '~> 1.4.2'

gem 'devise'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-linkedin-oauth2'
gem 'omniauth-twitter'
gem 'omniauth-facebook'

gem 'figaro'
# gem 'heroku_secrets', github: 'alexpeattie/heroku_secrets'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
  gem 'rspec'
  gem 'rspec-mocks'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'capybara'
end

group :test do
  gem 'spork'
  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-rspec', require: false
  gem 'guard-spork'
  gem 'minitest-reporters', '1.0.5'
  gem 'mini_backtrace',     '0.1.3'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
  gem 'puma',           '2.11.1'
end
