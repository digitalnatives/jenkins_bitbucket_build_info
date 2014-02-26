require 'sinatra'
require 'json'
require 'application_helpers'
require 'pull_request/approver'
require 'pull_request/hook_request_parser'

helpers ApplicationHelpers

get '/' do
  erb :index
end

post '/bitbucket/post_pull_request' do
  content_type 'text/plain'
  hook_request_parser = PullRequest::HookRequestParser.new(request.body.read)

  if hook_request_parser.can_trigger_a_build? && !redis.hget(build_key(hook_request_parser.attributes_hash), :sha)
    # TODO send a build request to jenkins
    redis.mapped_hmset build_key(hook_request_parser.attributes_hash), hook_request_parser.attributes_hash
  end
  logger.fatal 'bitbucket hook is not implemented'
  halt 501
end

get '/jenkins/post_build' do
  content_type 'text/plain'
  halt 400, 'Must provide commit sha!' unless params[:sha]

  build_payload = parse_build_payload(params)
  logger.info "JENKINS post_build: #{build_payload.to_json}"

  # Store the status of this sha for later
  redis.mapped_hmset build_key(build_payload), build_payload

  # Look for an open pull request with this SHA and approve it.
  PullRequest::PR.find(build_payload.sha).update_approval!(build_payload)
end

get '/:user/:repo/:sha/badge' do |user, repo, sha|
  build_succeeded = redis.hget(build_key(user: user, repo: repo, sha: sha), :succeeded)
  status = case build_succeeded
           when 'true'  then 'success'
           when 'false' then 'failure'
           else 'unknown'
           end

  logger.info "Build status of #{user}/#{repo}@#{sha} #{status}"
  send_file File.join(settings.public_folder, 'status', "#{status}.png")
end
