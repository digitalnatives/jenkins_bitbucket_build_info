require 'bitbucket_rest_api'

module ApplicationHelpers
  extend self

  def redis
    @redis ||= Redis.new # uses ENV['REDIS_URL'] by default
  end

  def bitbucket
    @bitbucket ||= BitBucket.new({basic_auth: ENV['BITBUCKET_CREDENTIALS']})
  end

  def build_key(user: nil, repo: nil, sha: nil, **other)
    "jenkins:build_info:#{user}:#{repo}:#{sha}"
  end

  def parse_build_payload(params)
    {
      sha:        params[:sha],
      job_name:   params[:job_name],
      job_number: params[:job_number],
      user:       params[:user],
      repo:       params[:repo],
      branch:     params[:branch],
      succeeded:  params[:status].to_s.downcase == 'success',
    }
  end
end

