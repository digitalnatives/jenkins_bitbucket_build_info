require 'ostruct'

class PullRequestApprover < OpenStruct
  def build_passed?
    !!succeeded
  end

  def pull_request
    @pull_request ||= all_pull_requests.find do |pr|
      sha.start_with?(pr.source.commit[:hash])
    end
  end

  def update_approval!
    return 'No pull-request found' unless pull_request

    action = build_passed? ? :approve : :unapprove
    bitbucket.repos.pullrequests.public_send(action, user, repo, pull_request.id)

    "#{action.to_s.capitalize} #{user}/#{repo}/pull-request/#{pull_request.id}"
  rescue BitBucket::Error::NotFound, BitBucket::Error::ServiceError => e
    e.message
  end

  private
  def all_pull_requests
    bitbucket.repos.pullrequests.all(user, repo)[:values]
  end

  def bitbucket
    ApplicationHelpers.bitbucket
  end
end
