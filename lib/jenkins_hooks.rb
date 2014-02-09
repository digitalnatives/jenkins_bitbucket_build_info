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

module JenkinsHooks

  def self.registered(app)
    app.get '/jenkins/post_build' do
      halt 400, 'Must provide commit sha!' unless params[:sha]

      build_payload = {
        sha:        params[:sha],
        job_name:   params[:job_name],
        job_number: params[:job_number],
        user:       params[:user],
        repo:       params[:repo],
        branch:     params[:branch],
        succeeded:  params[:status] == 'success',
      }
      logger.info "JENKINS post_build: #{build_payload.to_json}"

      # Store the status of this sha for later
      redis.mapped_hmset redis_key(build_payload), build_payload

      # Look for an open pull request with this SHA and approve it.
      PullRequestApprover.new(build_payload).update_approval!
    end
  end

end

register JenkinsHooks
