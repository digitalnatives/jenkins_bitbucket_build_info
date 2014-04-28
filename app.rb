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

  build = if hook_request_parser.can_trigger_a_build?
            Build.new(hook_request_parser.attributes_hash)
          end


  if build && build.new?
    build.submit

    username = hook_request_parser.username
    repository = hook_request_parser.repository
    sha = hook_request_parser.sha

    build_payload = CommitStatus.new({
      "job_name" => "",
      "job_number" => "",
      "branch" => "",
      "status" => "unknown",
      "sha" => sha,
      "user" => username,
      "repo" => repository
    }).to_h
    pull_request = PullRequest::PR.find(sha, username, repository)do
      url("/#{username}/#{repository}/%{sha}/badge")
    end
    pull_request.update_builds!(build_payload)

    logger.info "JENKINS build_submitted: #{build.attributes_hash}"
  end

end

get '/jenkins/post_build' do
  content_type 'text/plain'
  halt 400, 'Must provide commit sha!' unless params[:sha]

  params["user"], params["repo"] = params[:job_name].split('-',2)
  params["status"] = ApplicationHelpers.jenkins.job.get_build_details(params[:job_name], params[:job_number])["result"]

  build_payload = CommitStatus.new(params).to_h
  logger.info "JENKINS post_build: #{build_payload.to_json}"

  Build.new(build_payload).save

  user = build_payload[:user]
  repo = build_payload[:repo]
  sha = build_payload[:sha]

  # Look for an open pull request with this SHA and approve it.
  pull_request = PullRequest::PR.find(sha, user, repo) do
    logger.info "Approving sha: #{sha}!"
    url("/#{user}/#{repo}/%{sha}/badge")
  end
  pull_request.new_build!(build_payload) if pull_request
end

get '/:user/:repo/:sha/badge' do |user, repo, sha|
  build = Build.new(user: user, repo: repo, sha: sha)

  logger.info "Build status of #{user}/#{repo}@#{sha} #{build.status}"
  send_file File.join(settings.public_folder, 'status', "#{build.status}.png")
end
