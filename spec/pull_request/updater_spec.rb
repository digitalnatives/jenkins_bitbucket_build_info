require 'spec_helper'
require 'pull_request/updater'
require 'pull_request/build_log'

describe PullRequest::Updater do
  let(:pull_request) { double(:pull_request).as_null_object }
  let(:description) { "Pull request description" }
  let(:user) { "user" }
  let(:repo) { "repo" }
  let(:pull_request_updater) { PullRequest::Updater.new(user: "user", repo: "repo") }
  let(:build_log) { double(:build_log).as_null_object }
  let(:commit_hash) { "abcde123456789" }
  let(:status) { "passed" }
  let(:date) { Time.now.to_s }

  describe '#update_build' do
    before do
      pull_request.stub(description: description,
                        id: "123",
                        title: "Pull request title"
                       )
      pull_request_updater.stub_chain(pull_request: pull_request)
      pull_request_updater.stub_chain(:bitbucket, :repos, :pullrequests, :update)
      PullRequest::BuildLog.stub(:new).with(description).and_return(build_log)
    end

    it "adds the build to the build_log object" do
      build_log.should_receive(:add_build!).with(commit_hash, status, date)
      pull_request_updater.update_build(commit_hash, status, date)
    end

    it "updates the pull request with the new description" do
      build_log.should_receive(:to_s).and_return(description)
      pull_request_updater.should_receive(:update_pull_request).with( { description: description })

      pull_request_updater.update_build(commit_hash, status, date)
    end
  end
end
