require 'bitbucket_rest_api'

module ApplicationHelpers
  extend self

  def redis
    @redis ||= Redis.new(redis_hash)
  end

  def build_key(user: nil, repo: nil, sha: nil, **other)
    "jenkins:build_info:#{user}:#{repo}:#{sha}"
  end

  def bitbucket
    @bitbucket ||= BitBucket.new({basic_auth: ENV['BITBUCKET_CREDENTIALS']})
  end

  private
  def redis_hash
    uri = URI.parse(ENV['REDIS_URL'])
    {host: uri.host, port: uri.port, password: uri.password}
  end
end

