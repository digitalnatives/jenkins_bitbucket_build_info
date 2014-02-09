require 'json'
require 'redis_helpers'
require 'bitbucket_helpers'

require 'jenkins_hooks'
require 'bitbucket_hooks'

enable :inline_templates
helpers RedisHelpers, BitbucketHelpers
before { content_type 'text/plain' }

get '/' do
  content_type 'text/html'
  erb :index
end
