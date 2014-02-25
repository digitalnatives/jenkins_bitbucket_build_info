class PullRequest::HookRequestParser
  attr_reader :json_payload

  def initialize(json_payload)
    @json_payload = json_payload
  end

  def hook_type
    root.gsub("pullrequest_", "").to_sym
  end

  def username
    body.author.username
  end

  def repository
    body.destination.repository.full_name
  end

  def commit_hash
    case hook_type
    when :created
      body.source.commit[:hash]
    when :updated
      body.source.commit.sha
    else
      # This won't work for all cases, but is a frequent pattern.
      # The cases that it won't work do not concern our interests,
      # so this should be enough.
      body.source.commit[:hash]
    end
  end

  private

  def body
    json_payload.send(root)
  end

  def root
    json_payload.keys.first
  end
end
