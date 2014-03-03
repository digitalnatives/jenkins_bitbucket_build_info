require 'spec_helper'
require 'pull_request/approver'
require 'pull_request/updater'
require 'pull_request/build_log'
require 'pull_request/pr'

describe PullRequest::PR do
  let(:user) { "user" }
  let(:repo) { "repo" }
  let(:sha) { "sha" }

  PR_DATA_PATH = File.expand_path('../../fixtures/bitbucket/pull_request/pull_request.json', __FILE__)
  let(:bitbucket_data) { Hashie::Mash.new JSON.parse(File.read(PR_DATA_PATH)) }

  subject { described_class.new(user, repo, sha, bitbucket_data) }

  [:id, :description].each do |method|
    describe "##{method}" do
      it "looks for #{method} in bitbucket_data" do
        expect(subject.bitbucket_data).to receive(method)
        subject.public_send(method)
      end
    end
  end

  describe "#new_build!" do
    let(:payload) { double(:payload) }

    before do
      subject.stub(:update_approval!)
      subject.stub(:update_builds!)
    end

    it "updates the approval" do
      expect(subject).to receive(:update_approval!).with(payload)
      subject.new_build!(payload)
    end

    it "updates the builds" do
      expect(subject).to receive(:update_builds!).with(payload)
      subject.new_build!(payload)
    end
  end

  describe "#update_approval!" do
    let(:json_payload) { {} }
    let(:approver) { double(:approver).as_null_object }

    it "instantiates a new approver" do
      expect(PullRequest::Approver).to receive(:new).and_return(approver)
      subject.update_approval!(json_payload)
    end

    it "updates approval" do
      PullRequest::Approver.stub(new: approver)
      expect(approver).to receive(:update_approval!)
      subject.update_approval!(json_payload)
    end
  end

  describe "#update_builds!" do
    let(:json_payload) { {} }
    let(:updater) { double(:updater).as_null_object }

    it "instantiates a new updater" do
      expect(PullRequest::Updater).to receive(:new).and_return(updater)
      subject.update_builds!(json_payload)
    end

    it "updates builds" do
      PullRequest::Updater.stub(new: updater)
      expect(updater).to receive(:update_builds!)
      subject.update_builds!(json_payload)
    end
  end
end
