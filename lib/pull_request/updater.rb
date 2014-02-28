require 'ostruct'
require 'forwardable'

module PullRequest
  class Updater < OpenStruct
    extend Forwardable

    def_delegators :pull_request, :build_log, :user, :repo, :id

    def update_builds!
      return 'No pull-request found' unless pull_request

      build_log.add_build!(sha, date)

      update_pull_request(description: build_log.to_s)
    end

    private

    def updatable_attributes
      pull_request.bitbucket_data.select { |k, v| %w(close_source_branch title destination).include?(k) }
    end

    def update_pull_request(updated_attributes)
      PR.bitbucket_client.repos.pullrequests.update(user,
                                                    repo,
                                                    id,
                                                    updatable_attributes.merge(updated_attributes))
    end
  end
end

