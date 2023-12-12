class ApplicationJob
  include Sidekiq::Job # use sidekiq instead of active job for performance issue

  protected

  def debug_log(message)
    Sidekiq.logger.debug message
  end
end
