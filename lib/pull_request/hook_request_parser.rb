class PullRequest::HookRequestParser
  attr_reader :json_payload

  def initialize(json_payload)
    @json_payload = Hashie::Mash.new(JSON.parse(json_payload))
  end

  def hook_type
    @hook_type ||= root.gsub("pullrequest_", "").to_sym
  end

  def can_trigger_a_build?
    [:created, :updated].include?(hook_type) || restart_comment?
  end

  # The next methods won't work for all cases. The cases that they
  # won't work do not concern our interests, so this should be enough.
  def username
    destination.split('/').first
  end

  def repository
    destination.split('/').last
  end

  def destination
    if restart_comment?
      body.links.self.href.split(/(repositories|pullrequests)/)[2][1..-2]
    else
      body.destination.repository.full_name
    end
  end

  def sha
    full_sha = if restart_comment?
                 sha_match = body.content.raw.match(/\[ci restart (.*)\]/)
                 sha_match && sha_match[1]
               else
                 body.source.commit[:hash]
               end
    full_sha && full_sha[0..11]
  end

  def attributes_hash
    { user: username, sha: sha, repo: repository, restart: restart_comment? }
  end

  def restart_comment?
    if @restart_comment.nil?
      @restart_comment = (hook_type == :comment_created &&
                          body.content.raw.include?("[ci restart"))
    end
    @restart_comment
  end

  private

  def body
    json_payload.send(root)
  end

  def root
    json_payload.keys.first
  end
end
