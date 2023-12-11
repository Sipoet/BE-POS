Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://redis:6379/0' }
  config.logger.level = Rails.logger.level
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://redis:6379/0' }
end
