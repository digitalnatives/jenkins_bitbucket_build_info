require 'pull_request_approver'

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
