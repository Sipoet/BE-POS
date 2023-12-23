class ApplicationJob
  include Sidekiq::Job # use sidekiq instead of active job for performance issue

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
end
