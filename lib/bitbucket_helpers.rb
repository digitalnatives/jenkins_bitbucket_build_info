require 'bitbucket_rest_api'

module BitbucketHelpers
  def bitbucket
    @bitbucket ||= BitBucket.new({basic_auth: ENV['BITBUCKET_CREDENTIALS']})
  end
end
