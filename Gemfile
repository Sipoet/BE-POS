source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', "~> 7.1.2"

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'
gem 'kaminari', '~> 1.2.2'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.8'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[ mingw mswin x64_mingw jruby ]
gem 'rubyzip'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false
gem 'write_xlsx', '~> 1.11.1'
gem 'devise', '~>4.9.0'
gem 'devise-jwt', '~>0.11.0'
gem 'jsonapi-serializer', '~>2.2.0'
# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem 'image_processing', '~> 1.2'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'
gem 'sidekiq-cron', '~>1.12.0'
gem 'rswag-api', '~>2.13.0'
gem 'rswag-ui', '~>2.13.0'
gem 'sidekiq', '~> 7.2'
gem 'xsv','~> 1.3.0'
gem 'paper_trail','~> 15.1.0'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
  gem 'byebug'
  gem 'pry'
  gem 'rspec-rails', '~>6.1.0'
  gem 'rswag-specs', '~>2.13.0'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  gem 'spring'
  # gem 'parallel'
  gem 'solargraph'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-performance', require: false
end

group :test do
  gem 'database_cleaner-active_record', '~>2.1.0'
  gem 'database_cleaner-redis', '~>2.0.0'
  gem 'factory_bot_rails','~>6.4.2'
  gem 'ffaker', '~>2.23.0'
  gem 'rspec-sidekiq', '~>4.1.0'
end
