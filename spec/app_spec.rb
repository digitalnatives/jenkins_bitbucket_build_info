require 'spec_helper'

describe 'Application' do

  describe 'GET /' do
    it 'should be OK' do
      get '/'
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
      let(:pull_request_approver) { double(:pull_request_approver) }

      before do
        pull_request_approver.stub(:update_approval!)
      end

      it 'returns OK' do
        PullRequestApprover.stub(new: pull_request_approver)
        get '/jenkins/post_build', {
          sha:        '123456789abcdef',
          job_name:   'test',
          job_number: 'b123',
          user:       'trekdemo',
          repo:       'jenkins_bitbucket_build_info',
          branch:     'master',
          status:     'success',
        }
        expect(last_response).to be_ok
      end
    end
  end

end
