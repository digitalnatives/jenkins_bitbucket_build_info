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
    destination.split('/').first
  end

  def repository
    destination.split('/').last
  end

  def destination
    body.destination.repository.full_name
  end

  def sha
    body.source.commit[:hash][0..11]
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
