Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://redis:6379/0' }
  config.logger.level = Rails.logger.level
  config.on(:startup) do
    schedule_file = "#{Rails.root}/config/sidekiq_schedule.yml"

    if File.exist?(schedule_file)
      schedule = YAML.load_file(schedule_file)

      Sidekiq::Cron::Job.load_from_hash!(schedule, source: "schedule")
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://redis:6379/0' }
end
