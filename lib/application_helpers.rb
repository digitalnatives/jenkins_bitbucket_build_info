require 'bitbucket_rest_api'

module ApplicationHelpers
  extend self

  def redis
    @redis ||= Redis.new # uses ENV['REDIS_URL'] by default
  end

  def build_key(user: nil, repo: nil, sha: nil, **other)
    "jenkins:build_info:#{user}:#{repo}:#{sha}"
  end

  def bitbucket
    @bitbucket ||= BitBucket.new({basic_auth: ENV['BITBUCKET_CREDENTIALS']})
  end
end

