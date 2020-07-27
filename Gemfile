source 'https://rubygems.org'

# Ruby version.
ruby '2.7.1'

# Rails version.
gem 'rails', '~> 5.0'



# SQLite3 database.
group :development, :test do
  gem 'sqlite3', '>= 1.3.6'
end

# MySQL2 database for Google Cloud SQL.
group :development, :production do
  gem 'mysql2'
end

# PostgreSQL database for Heroku. (Not used)
group :production do
  gem 'pg', '>= 0.19.0'
end

# Mechanize for web scraping.
gem 'mechanize'

# Draw graph.
gem 'chartkick', '>= 3.3.0'

gem 'rails-ujs'

# AJAX web scraping.
gem 'capybara'
gem 'poltergeist'

# Add log.
gem 'rails_12factor'

# Lock version.
gem 'nokogiri', '>= 1.10.4'
gem 'loofah', '>= 2.3.1'



# Use SCSS for stylesheets
gem 'sass-rails', '>= 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '>= 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '>= 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '>= 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '>= 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

