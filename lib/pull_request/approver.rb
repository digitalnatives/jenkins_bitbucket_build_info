require 'ostruct'

module PullRequest
  class Approver < OpenStruct
    def build_passed?
      !!succeeded
    end

    def update_approval!
      return 'No pull-request found' unless pull_request

      action = build_passed? ? :approve : :unapprove
      PR.bitbucket_client.repos.pullrequests.public_send(action, user, repo, pull_request.id)

      "#{action.to_s.capitalize} #{user}/#{repo}/pull-request/#{pull_request.id}"
    rescue BitBucket::Error::NotFound, BitBucket::Error::ServiceError => e
      e.message
    end
  end
end
