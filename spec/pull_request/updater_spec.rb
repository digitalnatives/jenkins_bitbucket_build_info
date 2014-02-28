require 'spec_helper'
require 'pull_request/updater'
require 'pull_request/build_log'
require 'pull_request/pr'

describe PullRequest::Updater do
  let(:bitbucket_data) {
    Hashie::Mash.new(JSON.parse(File.read("spec/fixtures/bitbucket/pull_request/pull_request.json")))
  }
  let(:pull_request) { PullRequest::PR.new(user, repo, sha, bitbucket_data) }
  let(:description) { "Pull request description" }
  let(:user) { "user" }
  let(:repo) { "repo" }
  let(:pull_request_updater) { PullRequest::Updater.new(date: date,
                                                        sha: sha,
                                                        pull_request: pull_request) }
  let(:build_log) { double(:build_log).as_null_object }
  let(:sha) { "abcde123456789" }
  let(:status) { "passed" }
  let(:date) { Time.now.to_s }

  describe '#update_builds!' do
    before do
      pull_request.stub(description: description,
                        id: 123,
                        title: "Pull request title",
                        build_log: build_log
                       )
      pull_request_updater.stub_chain(pull_request: pull_request)
      pull_request_updater.stub_chain(:bitbucket, :repos, :pullrequests, :update)
      PullRequest::PR.stub_chain(:bitbucket_client, :repos, :pullrequests, :update)
    end

    it "adds the build to the build_log object" do
      build_log.should_receive(:add_build!).with(sha, date)
      pull_request_updater.update_builds!
    end

    it "updates the pull request with the new description" do
      build_log.should_receive(:to_s).and_return(description)
      pull_request_updater.should_receive(:update_pull_request).with( { description: description })

      pull_request_updater.update_builds!
    end
  end
end
