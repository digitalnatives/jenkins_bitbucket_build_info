require 'sinatra'
require 'json'
require 'application_helpers'
require 'pull_request/approver'
require 'pull_request/hook_request_parser'
require 'pull_request/pr'
require 'build'

helpers ApplicationHelpers

get '/' do
  erb :index
end

post '/bitbucket/post_pull_request' do
  content_type 'text/plain'
  request_body = request.body.read
  logger.info "BITBUCKET post_hook: #{request_body}"
  hook_request_parser = PullRequest::HookRequestParser.new(request_body)
  build = Build.new(hook_request_parser.attributes_hash)

  if hook_request_parser.can_trigger_a_build? && build.new?
    logger.info "JENKINS build_submitted: #{build.attributes_hash}"
    build.submit
  end
end

get '/jenkins/post_build' do
  content_type 'text/plain'
  halt 400, 'Must provide commit sha!' unless params[:sha]

  build_payload = CommitStatus.new(params).to_h
  logger.info "JENKINS post_build: #{build_payload.to_json}"

  Build.new(build_payload).save

  # Look for an open pull request with this SHA and approve it.
  pull_request = PullRequest::PR.find(build_payload[:sha], build_payload[:user], build_payload[:repo])
  pull_request.new_build!(build_payload) if pull_request.exists?
end

get '/:user/:repo/:sha/badge' do |user, repo, sha|
  build = Build.new(user: user, repo: repo, sha: sha)

  logger.info "Build status of #{user}/#{repo}@#{sha} #{buil.status}"
  send_file File.join(settings.public_folder, 'status', "#{build.status}.png")
end
