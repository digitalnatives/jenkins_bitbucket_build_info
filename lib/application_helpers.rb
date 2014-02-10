require 'bitbucket_rest_api'

module ApplicationHelpers
  def redis
    @redis ||= Redis.new(ENV['REDIS_URL'])
  end

  def redis_key(user: nil, repo: nil, sha: nil, **other)
    "jenkins:build_info:#{user}:#{repo}:#{sha}"
  end

  def bitbucket
    @bitbucket ||= BitBucket.new({basic_auth: ENV['BITBUCKET_CREDENTIALS']})
  end
end

