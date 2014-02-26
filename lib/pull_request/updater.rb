require 'ostruct'

module PullRequest
  class Updater < OpenStruct
    def update_build!(commit_hash, status, date = nil)
      return 'No pull-request found' unless pull_request

      build_log = PullRequest::BuildLog.new(pull_request.description)
      build_log.add_build!(commit_hash, status, date)

      update_pull_request(description: build_log.to_s)
    end

    private

    def updatable_attributes
      pull_request.bitbucket_data.select { |k, v| %w(close_source_branch title destination).include?(k) }
    end

    def update_pull_request(updated_attributes)
      PR.bitbucket_client.repos.pullrequests.update(user,
                                                    repo,
                                                    pull_request.id,
                                                    updatable_attributes.merge(updated_attributes))
    end
  end
end

