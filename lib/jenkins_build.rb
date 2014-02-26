class JenkinsBuild < Hashie::Mash
  def succeeded?
    status.to_s.downcase == 'success'
  end

  def pull_request
    @pull_request = PullRequest.new(PullRequest.bitbucket_pull_request(user, repo, sha))
  end

  def update_pull_request_approval!
    if succeeded?
      pull_request.approve!
    else
      pull_request.unnaprove!
    end
  end
end
