require 'bitbucket_rest_api'
require 'commit_status'

module ApplicationHelpers
  extend self

  def redis
    @redis ||= Redis.new # uses ENV['REDIS_URL'] by default
  end

  def bitbucket
    @bitbucket ||= if ENV['BITBUCKET_OAUTH_TOKEN'] && ENV['BITBUCKET_OAUTH_SECRET']
                     BitBucket.new(oauth_token: ENV['BITBUCKET_OAUTH_TOKEN'],
                                   oauth_secret: ENV['BITBUCKET_OAUTH_SECRET'])
                   else
                     BitBucket.new(basic_auth: ENV['BITBUCKET_CREDENTIALS'])
                   end
  end

  def build_key(user: nil, repo: nil, sha: nil, **other)
    "build_info:#{user}:#{repo}:#{sha}"
  end

  def parse_build_payload(params)
    CommitStatus.new(params).to_h
  end
end

