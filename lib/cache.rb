class Cache
  @@redis = Redis.new
  def self.get(key)
    @@redis.get(key)
  end
  def self.set(key, value)
    @@redis.set(key, value)
  end
end
