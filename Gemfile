source "https://rubygems.org"

gem 'sinatra'
gem 'redis'
gem 'bitbucket_rest_api', github: 'digitalnatives/bitbucket'
gem 'dotenv'
gem 'passenger'
gem 'jenkins_api_client', '1.0.0.beta.6'
gem 'curb', '~> 0.8.5'

gem 'rake'

group :development do
  gem 'foreman', require: false
  gem 'shotgun', require: false
  gem 'pry-byebug',  require: false
  gem 'guard-rspec', require: false
end

group :test do
  gem 'mock_redis'
  gem 'rspec'
  gem 'rack-test'
end
