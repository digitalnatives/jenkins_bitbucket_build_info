require 'ostruct'

module PullRequest
  class Updater < OpenStruct
    def pull_request
      @pull_request ||= all_pull_requests.find do |pr|
        sha.start_with?(pr.source.commit[:hash])
      end
    end

    def update_build(commit_hash, status, date = nil)
      build_log = PullRequest::BuildLog.new(pull_request.description)
      build_log.add_build!(commit_hash, status, date)

      update_pull_request(description: build_log.to_s)
    end

    private

    def pull_request_updatable_attributes
      pull_request.select { |k, v| %w(close_source_branch title destination destination).include?(k) }
    end

    def update_pull_request(updated_attributes)
      bitbucket.repos.pullrequests.update(user,
                                          repo,
                                          pull_request.id,
                                          pull_request_updatable_attributes.merge(updated_attributes))
    end

    def all_pull_requests
      bitbucket.repos.pullrequests.all(user, repo)[:values]
    end

    def bitbucket
      ApplicationHelpers.bitbucket
    end
  end
end

