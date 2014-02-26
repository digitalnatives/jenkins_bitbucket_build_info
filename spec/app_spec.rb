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
    it "fails because the action is not implemented" do
      post '/bitbucket/post_pull_request', File.read("spec/fixtures/bitbucket/pull_request/created.json")
      expect(last_response.status).to eql 501
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
        PullRequest::PR.stub_chain(:find, :update_approval!)
      end

      it "receives a hash with parsed data" do
        PullRequest::PR.stub(find: pull_request)
        pull_request.should_receive(:update_approval!).with(build_parameters)
        get '/jenkins/post_build', build_parameters
      end

      it 'returns OK' do
        get '/jenkins/post_build', build_parameters
        expect(last_response).to be_ok
      end
    end
  end

end
