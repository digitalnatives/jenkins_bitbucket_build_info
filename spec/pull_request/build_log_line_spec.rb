require 'spec_helper'
require 'pull_request/build_log_line'

describe BuildLogLine do
  DATE_FORMAT = BuildLogLine::DATE_FORMAT

  let(:status) { { sha: '1f4ad90294d3fd7ab5cebe42ee97655c2e709bbf', date: '2014/02/21' } }
  let(:line) { "![badge](/user/repo/1f4ad90294d3fd7ab5cebe42ee97655c2e709bbf/badge) [commit details](https://bitbucket.org/user/repo/commits/1f4ad90294d3fd7ab5cebe42ee97655c2e709bbf) 2014/02/21" }

  let(:build_line_from_string) { BuildLogLine.from_string(line) }
  let(:build_line_from_status) { BuildLogLine.from_status(status) }

  describe '.from_string' do
    it "parses the date correctly" do
      expect(build_line_from_string.date).to eq(Date.strptime(status[:date].to_s, DATE_FORMAT))
    end

    it "parses the sha correctly" do
      expect(build_line_from_string.sha).to eq(status[:sha])
    end
  end

  describe '.from_status' do
    it "saves the sha" do
      expect(build_line_from_status.sha).to eq status[:sha]
    end

    it "saves the date" do
      expect(build_line_from_status.date.strftime(DATE_FORMAT)).to eq status[:date]
    end

    it "leaves nil on date if it is not present" do
      expect(BuildLogLine.from_status(sha: status[:sha]).date).to be_nil
    end
  end

  describe "#formatted_date" do
    let(:build_log_line_with_nil_date) { BuildLogLine.from_status(sha: "some_sha") }

    it "is nil when date is nil" do
      expect(build_log_line_with_nil_date.formatted_date).to be_nil
    end
  end

  describe '#eql?' do
    let(:line_1) { described_class.from_status(sha: '1f4ad90294d3fd7ab5cebe42ee97655c2e709bbf', date: '2013/12/31') }
    let(:line_2) { described_class.from_status(sha: 'a4cad4e4c24ab53a725fe8953c2d587dd34573e1', date: '2014/01/10') }
    let(:line_3) { described_class.from_status(sha: '1f4ad90294d3fd7ab5cebe42ee97655c2e709bbf', date: '2014/01/12') }

    specify { expect(line_1).to be_eql(line_1) }
    specify { expect(line_1).to_not be_eql(line_2) }
    specify { expect(line_1).to be_eql(line_3) }
  end

end
