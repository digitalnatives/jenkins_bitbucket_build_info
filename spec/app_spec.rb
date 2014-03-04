require 'spec_helper'
require 'pull_request/pr'

describe 'Application' do

  describe 'GET /' do
    it 'should be OK' do
      get '/'
      expect(last_response).to be_ok
    end
  end

  describe 'POST /bitbucket/post_pull_request' do

    def post_to_hook
      post '/bitbucket/post_pull_request', File.read("spec/fixtures/bitbucket/pull_request/created.json")
    end

    let(:hook_request_parser) { double(:hook_request_parser).as_null_object }
    let(:build) { double(:build).as_null_object }

    before do
      Build.stub(new: build)
      PullRequest::HookRequestParser.stub(new: hook_request_parser)
    end

    context "does not submit a new build when" do
      it "has new commits which have already been built" do
        hook_request_parser.stub(can_trigger_a_build?: true)
        build.stub(new?: false)
        expect(build).not_to receive(:submit)
        post_to_hook
      end

      it "has no new commits" do
        hook_request_parser.stub(can_trigger_a_build?: false)
        expect(build).not_to receive(:submit)
        post_to_hook
      end
    end

    it "submits a new build and returns OK" do
      hook_request_parser.stub(can_trigger_a_build?: true)
      build.stub(new?: true)
      expect(build).to receive(:submit)
      post_to_hook
      expect(last_response).to be_ok
    end
  end

  describe 'GET /jenkins/post_build' do
    context 'without sha' do
      it 'returns an error page' do
        get '/jenkins/post_build'
        expect(last_response.status).to eql 400
        expect(last_response.body).to eql 'Must provide commit sha!'
      end
    end

    context 'when payload is present' do
      let(:pull_request) { double(:pull_request) }
      let(:build_parameters) { {
          sha:        '123456789abcdef',
          job_name:   'test',
          job_number: 'b123',
          user:       'trekdemo',
          repo:       'jenkins_bitbucket_build_info',
          branch:     'master',
          status:     'success',
        }
      }

      before do
        CommitStatus.stub_chain(:new, :to_h).and_return(build_parameters)
      end

      it "updates the pull request that it finds" do
        PullRequest::PR.stub(find: pull_request)
        pull_request.should_receive(:new_build!).with(build_parameters)
        get '/jenkins/post_build', build_parameters
        expect(last_response).to be_ok
      end

      it "does not update any pull request if it can't find one" do
        PullRequest::PR.stub(:find)
        expect(PullRequest::PR.any_instance).not_to receive(:new_build!)
        get '/jenkins/post_build', build_parameters
      end
    end
  end

end
