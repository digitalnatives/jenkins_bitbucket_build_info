
class Build
  attr_reader :attributes_hash

  STATUSES = %w(success failure unknown).freeze
  SUCCESS = STATUSES.first
  UNKNOWN = STATUSES.last

  def initialize(attributes_hash)
    @attributes_hash = attributes_hash
  end

  def new?
    !self.class.redis.hget(key, :sha)
  end

  def save
    self.class.redis.mapped_hmset key, attributes_hash
  end

  def submit
    ApplicationHelpers.jenkins.job.build(@attributes_hash[:username]+"-"+@attributes_hash[:repository], {SHA: @attributes_hash[:sha]})
    save
  end

  def key
    ApplicationHelpers.build_key(attributes_hash)
  end

  def passed?
    status == Build::SUCCESSS
  end

  def stored_status
    @stored_status ||= self.class.redis.hget(key, :status)
  end

  def status
    if Build.known_status?(stored_status)
      stored_status
    else
      Build::UNKNOWN
    end
  end

  def self.known_status?(status)
    STATUSES.include? status
  end

  def self.redis
    ApplicationHelpers.redis
  end
end
