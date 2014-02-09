module RedisHelpers
  def redis
    @redis ||= Redis.new
  end

  def redis_key(user: nil, repo: nil, sha: nil, **other)
    "jenkins.build_info.#{user}/#{repo}.#{sha}"
  end
end

