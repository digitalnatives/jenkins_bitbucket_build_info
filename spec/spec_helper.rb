ENV['RACK_ENV'] = 'test'
ENV['JENKINS_URL'] = 'http://url.to.jenkins'

require File.expand_path('../../environment.rb', __FILE__)
require File.expand_path('../../app.rb', __FILE__)
require 'rack/test'
require 'mock_redis'

module RSpecMixin
  include Rack::Test::Methods
  def app; Sinatra::Application; end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'

  config.before(:each) do
    redis_instance = MockRedis.new
    Redis.stub(:new).and_return(redis_instance)
  end
end
