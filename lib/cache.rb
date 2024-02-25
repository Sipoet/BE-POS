class Cache
  @@redis = Redis.new(url: 'redis://redis:6379/1')
  def self.get(key)
    @@redis.get(key)
  end
  def self.set(key, value)
    @@redis.set(key, value)
  end

  def self.keys(namespace)
    @@redis.keys("*#{namespace}*")
  end

  def self.delete_namespace(key)
    keys = @@redis.keys("*#{key}*")
    @@redis.del(keys)
  end
end
