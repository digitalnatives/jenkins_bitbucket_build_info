require 'spec_helper'
require 'pull_request/build_log_line'

describe BuildLogLine do

  describe '.from_string' do
    pending
  end

  describe '.from_status' do
    pending
  end

  describe '#line' do
    context 'when instantiated from string'
    context 'when instantiated from status'
  end

  describe '#sha' do
    context 'when instantiated from string'
    context 'when instantiated from status'
  end

  describe '#date' do
    context 'when instantiated from string'
    context 'when instantiated from status'
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
