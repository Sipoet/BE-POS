class RestoreDbJob < ApplicationJob
  sidekiq_options queue: 'default', retry: false

  def perform(file_path, restore_db = nil)
    return unless File.exist?(file_path)

    config_db = Rails.configuration.database_configuration[Rails.env]
    db = restore_db || config_db['database']
    "pg_restore -U #{config_db['username']} -d #{db} -h #{config_db['host']} -p #{config_db['port']} -W #{file_path}"
  end
end
