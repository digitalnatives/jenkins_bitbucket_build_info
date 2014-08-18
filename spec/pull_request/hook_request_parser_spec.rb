require 'spec_helper'
require 'pull_request/hook_request_parser'

describe PullRequest::HookRequestParser do
  def pull_request_fixture(name)
    File.read("spec/fixtures/bitbucket/pull_request/#{name}.json")
  end

  def fixture_hook_parser(name)
    PullRequest::HookRequestParser.new(pull_request_fixture(name))
  end

  let(:created_hook_parser) { fixture_hook_parser("created") }
  let(:updated_hook_parser) { fixture_hook_parser("updated") }
  let(:comment_created_hook_parser) { fixture_hook_parser("comment_created") }

  describe "#hook_type" do
    context "is parsed correctly when pull request is created" do
      specify "created" do
        expect(created_hook_parser.hook_type).to eq(:created)
      end

      specify "updated" do
        expect(updated_hook_parser.hook_type).to eq(:updated)
      end

      specify "comment_created" do
        expect(comment_created_hook_parser.hook_type).to eq(:comment_created)
      end
    end
  end

  describe "#username" do
    context "is parsed correctly when a pull request is" do
      specify "created" do
        expect(created_hook_parser.username).to eq("evzijst")
      end

      specify "updated" do
        expect(updated_hook_parser.username).to eq("detkin")
      end

      specify "comment_created" do
        expect(comment_created_hook_parser.username).to eq("evzijst")
      end
    end
  end


  describe "#repository" do
    context "is parsed correctly when a pull request is" do
      specify "created" do
        expect(created_hook_parser.repository).to eq("bitbucket2")
      end

      specify "updated" do
        expect(updated_hook_parser.repository).to eq("test")
      end

      specify "comment_created" do
        expect(comment_created_hook_parser.repository).to eq("bitbucket2")
      end
    end
  end


  describe "#sha" do
    context "is parsed correctly when a pull request is" do
      specify "created" do
        expect(created_hook_parser.sha).to eq("325625d47b0a")
      end

      pending "updated" do
        expect(updated_hook_parser.sha).to eq("6ddd631f33de")
      end

      specify "comment_created" do
        expect(comment_created_hook_parser.sha).to eq("4b82a6c2f8d3")
      end
    end
  end

  describe "#restart_comment?" do
    context 'when is a different hook_type' do
      specify 'is false' do
        expect(created_hook_parser.restart_comment?).to be_false
      end
    end

    context 'when it does not contain the pattern' do
      before :each do
        comment_created_hook_parser.stub_chain(:body, :content, :raw).and_return("Some normal comment")
      end

      specify 'is false' do
        expect(comment_created_hook_parser.restart_comment?).to be_false
      end
    end

    context 'when it contains the pattern' do
      specify 'is true' do
        expect(comment_created_hook_parser.restart_comment?).to be_true
      end
    end
  end
end
