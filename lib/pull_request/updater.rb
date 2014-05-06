require 'ostruct'
require 'forwardable'

module PullRequest
  class Updater < OpenStruct
    extend Forwardable

    def_delegators :pull_request, :build_log, :user, :repo, :id
    attr_reader :job_number

    def initialize(payload)
      super
      @job_number = payload[:job_number] || ""
    end

    def update_builds!
      return 'No pull-request found' unless pull_request

      build_log.add_build!(sha, date, job_number)

      update_pull_request(description: build_log.to_s)
      "UPDATE #{user}/#{repo}/pull-request/#{id}"
    rescue BitBucket::Error::NotFound, BitBucket::Error::ServiceError => e
      e.message
    end

    private

    def updatable_attributes
      pull_request.bitbucket_data.select { |k, v| %w(close_source_branch title destination reviewers).include?(k) }
    end

    def update_pull_request(updated_attributes)
      PR.bitbucket_client.repos.pullrequests.update(user,
                                                    repo,
                                                    id,
                                                    updatable_attributes.merge(updated_attributes))
    end
  end
end

