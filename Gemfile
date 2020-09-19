source 'https://rubygems.org'

gem 'dotenv-rails', groups: [:development, :test]
gem 'rails', '~> 6.0.3', '>= 6.0.3.3'
gem 'puma', '~> 3.7'
gem 'line-bot-api'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'pry-rails'

group :production do
  gem 'pg', '0.18.4'
end

group :development, :test do
  gem 'sqlite3'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rspec-rails'
  gem 'rails-controller-testing'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]