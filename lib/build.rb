
class Build
  attr_reader :attributes_hash

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
    #TODO submit to jenkins
    save
  end

  def key
    ApplicationHelpers.build_key(attributes_hash)
  end

  def success
    @success ||= redis.hget(key, :succeeded)
  end

  def status
    case success
    when 'true'  then 'success'
    when 'false' then 'failure'
    else 'unknown'
    end
  end

  def self.redis
    ApplicationHelpers.redis
  end
end
