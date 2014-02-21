require 'bitbucket_rest_api'
require 'commit_status'

module ApplicationHelpers
  extend self

  def redis
    @redis ||= Redis.new # uses ENV['REDIS_URL'] by default
  end

  def bitbucket
    @bitbucket ||= BitBucket.new({basic_auth: ENV['BITBUCKET_CREDENTIALS']})
  end

  def build_key(user: nil, repo: nil, sha: nil, **other)
    "build_info:#{user}:#{repo}:#{sha}"
  end

  def parse_build_payload(params)
    CommitStatus.new(params).to_h
  end
end

