require 'spec_helper'
require 'build'

describe Build do
  subject { Build.new({}) }

  let(:build_with_success_status) {
    Build.new({
      user: "test",
      repo: "test",
      sha: "abcdef0123456",
      status: "success"
    })
  }

  before do
    build_with_success_status.save
  end

  describe "#new?" do
    it "returns false when the build has already been saved" do
      expect(subject).to be_new
    end

    it "returns false when the build has already been saved" do
      expect(build_with_success_status).not_to be_new
    end
  end

  describe "#status" do
    it "returns unknown when the value is not in known statuses" do
      expect(subject.status).to eq("unknown")
    end

    context "when is known" do
      it "is returned" do
        expect(build_with_success_status.status).to eq("success")
      end
    end
  end
end
