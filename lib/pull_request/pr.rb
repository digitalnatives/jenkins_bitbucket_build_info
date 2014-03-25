require 'json'
require 'pull_request/approver'
require 'pull_request/build_log'
require 'pull_request/updater'

# This name is terrible :( ... But I wanted to avoid name
# colisions with the module name
class PullRequest::PR

  attr_reader :user, :repo, :sha, :attr_reader, :badge_url

  def initialize(user, repo, sha, badge_url, bitbucket_data = nil)
    @user = user
    @repo = repo
    @sha = sha
    @bitbucket_data = bitbucket_data
    @badge_url = badge_url
  end

  def id
    @id ||= bitbucket_data.id
  end

  def description
    @description ||= bitbucket_data.description
  end

  def build_log
    @build_log ||= PullRequest::BuildLog.new(description, user, repo, badge_url)
  end

  def new_build!(build_payload)
    update_approval!(build_payload)
    update_builds!(build_payload)
  end

  def update_approval!(json_payload)
    PullRequest::Approver.new(json_payload.merge(pull_request: self)).update_approval!
  end

  def update_builds!(json_payload)
    PullRequest::Updater.new(json_payload.merge(pull_request: self)).update_builds!
  end

  def bitbucket_data
    @bitbucket_data ||= self.class.find_bitbucket_pull_request(user, repo, sha)
  end

  def self.all(user, repo)
    bitbucket_client.repos.pullrequests.all(user, repo)[:values]
  end

  def self.find(sha, user, repo)
    if found_pull_request = find_bitbucket_pull_request(sha, user, repo)
      badge_url = yield if block_given?
      new(user, repo, sha, badge_url, found_pull_request)
    end
  end

  def self.find_bitbucket_pull_request(sha, user, repo)
    all(user, repo).find { |pr| sha.start_with?(pr.source.commit[:hash]) }
  end

  def self.bitbucket_client
    ApplicationHelpers.bitbucket
  end
end
