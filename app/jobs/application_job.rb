class ApplicationJob
  include Sidekiq::Job # use sidekiq instead of active job for performance issue

  def dont_run_in_parallel!
    lock_key = self.class.to_s
    lock = Cache.get(lock_key)
    if lock.nil?
      Cache.set(lock_key,'1')
    else
      raise PreventRunParallelError.new(lock_key)
    end
    yield
    Sidekiq.logger.info("lock key #{lock_key}")
    Cache.delete(lock_key)
  end

  def cancelled?
    Sidekiq.redis { |c| c.exists("cancelled-#{jid}") == 1 } # Use c.exists? on Redis >= 4.2.0
  end

  def self.cancel!(jid)
    Sidekiq.redis { |c| c.set("cancelled-#{jid}", 1) }
  end

  def check_if_cancelled!
    raise JobCancelled if cancelled?
  end
  protected

  def debug_log(message)
    Sidekiq.logger.debug message
  end

  class JobCancelled < StandardError;end
  class PreventRunParallelError < StandardError;end
end
