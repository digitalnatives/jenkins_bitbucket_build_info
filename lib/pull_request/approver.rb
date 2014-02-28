require 'forwardable'
require 'ostruct'

module PullRequest
  class Approver < OpenStruct
    extend Forwardable

    def_delegators :pull_request, :user, :repo, :id

    def build_passed?
      !!succeeded
    end

    def update_approval!
      return 'No pull-request found' unless pull_request

      action = build_passed? ? :approve : :unapprove
      PR.bitbucket_client.repos.pullrequests.public_send(action, user, repo, id)

      "#{action.to_s.capitalize} #{user}/#{repo}/pull-request/#{id}"
    rescue BitBucket::Error::NotFound, BitBucket::Error::ServiceError => e
      e.message
    end
  end
end
