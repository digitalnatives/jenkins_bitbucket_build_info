PullRequestApprover = Struct.new(:build_payload) do
  include BitbucketHelpers

  def user
    build_payload[:user]
  end

  def repo
    build_payload[:repo]
  end

  def commit_sha
    build_payload[:sha]
  end

  def build_passed?
    !!build_payload[:succeeded]
  end

  def pull_request
    @pull_request ||= all_pull_requests.find do |pr|
      commit_sha.start_with?(pr.source.commit[:hash])
    end
  end

  def update_approval!
    if pull_request && build_passed?
      bitbucket.repos.pullrequests.approve(user, repo, pull_request.id)
    else
      bitbucket.repos.pullrequests.unapprove(user, repo, pull_request.id)
    end

    "Approval status updated on #{user}/#{repo}/pull-request/#{pull_request.id}"
  rescue BitBucket::Error::NotFound, BitBucket::Error::ServiceError => e
    e.message
  end

  private
  def all_pull_requests
    bitbucket.repos.pullrequests.all(user, repo)[:values]
  end
end
