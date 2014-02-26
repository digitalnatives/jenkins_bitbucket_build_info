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

  describe "#hook_type" do
    context "is parsed correctly when pull request is created" do
      specify "created" do
        expect(created_hook_parser.hook_type).to eq(:created)
      end

      specify "updated" do
        expect(updated_hook_parser.hook_type).to eq(:updated)
      end
    end
  end

  describe "#username" do
    context "is parsed correctly when a pull request is" do
      specify "created" do
        expect(created_hook_parser.username).to eq("evzijst")
      end

      specify "updated" do
        expect(updated_hook_parser.username).to eq("evzijst")
      end
    end
  end


  describe "#repository" do
    context "is parsed correctly when a pull request is" do
      specify "created" do
        expect(created_hook_parser.repository).to eq("evzijst/bitbucket2")
      end

      specify "updated" do
        expect(updated_hook_parser.repository).to eq("detkin/test")
      end
    end
  end


  describe "#sha" do
    context "is parsed correctly when a pull request is" do
      specify "created" do
        expect(created_hook_parser.sha).to eq("325625d47b0a")
      end

      specify "updated" do
        expect(updated_hook_parser.sha).to eq("6ddd631f33de")
      end
    end
  end
end
