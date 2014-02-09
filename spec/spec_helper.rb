ENV['RACK_ENV'] = 'test'

require File.expand_path('../../environment.rb', __FILE__)
require File.expand_path('../../app.rb', __FILE__)
require 'rack/test'

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
end
