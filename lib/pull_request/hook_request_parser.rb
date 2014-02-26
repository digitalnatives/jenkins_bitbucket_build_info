class PullRequest::HookRequestParser
  attr_reader :json_payload

  def initialize(json_payload)
    @json_payload = Hashie::Mash.new(JSON.parse(json_payload))
  end

  def hook_type
    @hook_type ||= root.gsub("pullrequest_", "").to_sym
  end

  def can_trigger_a_build?
    [:created, :updated].include?(hook_type)
  end

  # The next methods won't work for all cases. The cases that they
  # won't work do not concern our interests, so this should be enough.
  def username
    body.author.username
  end

  def repository
    body.destination.repository.full_name
  end

  def sha
    case hook_type
    when :created
      body.source.commit[:hash]
    when :updated
      body.source.commit.sha
    else
      body.source.commit[:hash]
    end
  end

  def attributes_hash
    { user: username, sha: sha, repo: repository }
  end

  private

  def body
    json_payload.send(root)
  end

  def root
    json_payload.keys.first
  end
end
