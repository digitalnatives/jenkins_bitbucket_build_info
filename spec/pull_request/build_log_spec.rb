require 'spec_helper'
require 'pull_request/build_log'

describe PullRequest::BuildLog do
  PR_DESCRIPTION_PATH = File.expand_path('../../fixtures/bitbucket/pull_request/pr_description.txt', __FILE__)

  let(:description_string) { File.read(PR_DESCRIPTION_PATH) }

  subject { described_class.new(description_string) }

  describe ".initialize" do
    let(:build_statuses) do
      [
        { sha: "1f4ad90294d3fd7ab5cebe42ee97655c2e709bbf",
          status: :passed,
          date: "2014/02/21" },
        { sha: "a4cad4e4c24ab53a725fe8953c2d587dd34573e1",
          status: :failed,
          date: "2014/02/20" },
      ]
    end

    it "stores the part of the description not related to Jenkins builds" do
      expect(subject.normal_description).to eq "Not build related description"
    end

    it "transforms Jenkins builds list into a hash with expected values" do
      build_log_lines = build_statuses.map {|l| BuildLogLine.from_status(l) }

      expect(subject.build_lines.to_a).to match_array build_log_lines
    end
  end

  describe "#to_s" do
    it "regenerates previous description string" do
      expect(subject.to_s).to eq(description_string)
    end
  end

  describe "#add_build!" do
    it 'should insert a new line into the description' do
      subject.add_build!('8888888888888888888888888888888888888888', :failed, '2014/02/23')
      expect(subject.to_s).to eql "#{description_string.rstrip}\n![failed_build_image] 8888888888888888888888888888888888888888 2014/02/23\n"
    end
  end

end
