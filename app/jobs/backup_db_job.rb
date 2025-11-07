# frozen_string_literal: true

class BackupDbJob < ApplicationJob
  sidekiq_options queue: 'low', retry: false

  def perform
    config_db = Rails.configuration.database_configuration[Rails.env]
    backup_dir = '/backups'
    create_dir(backup_dir)
    file_path = generate_file_path(config_db, backup_dir)
    backup_db(config_db, file_path)
    remove_old_backup(backup_dir, before_time: 1.month.ago)
  end

  private

  def backup_db(config_db, file_path)
    on_db_scope(config_db) do
      system('pg_dump', '--host', config_db['host'], '--port', config_db['port'].to_s,
             '--username', config_db['username'],
             '--clean', '--no-owner', '--no-password',
             '--format', 'c', config_db['database'], '-f', file_path, exception: true)
    end
  end

  def generate_file_path(config_db, dir)
    db = config_db['database']
    date_txt = Time.zone.now.strftime('%y%m%d%H%M%S')
    "#{dir}/#{db}_backup_#{date_txt}.dump"
  end

  def remove_old_backup(dir, before_time:)
    files = get_file_on_folder(dir)
    total_db = files.length
    limit_db = Setting.get('number_of_db_saved') || 50
    files.sort_by(&:ctime).each do |file|
      ctime = file.ctime
      file.close
      next unless ctime <= before_time || total_db > limit_db

      delete_file(file)
      total_db -= 1
    end
  end

  def delete_file(file)
    Sidekiq.logger.debug "==========DELETE #{file.path}"
    File.delete(file.path)
  end

  def get_file_on_folder(dir)
    files = []
    Dir["#{dir}/*.dump"].each do |file_path|
      file = File.open(file_path, 'r')
      next if file.nil?

      files << file
    end
    files
  end

  def create_dir(path)
    Dir.mkdir(path) unless Dir.exist?(path)
  end

  def change_file_permission(path)
    FileUtils.chmod 0o600, path, verbose: true
  end

  def on_db_scope(config_db)
    pg_pass_path = "#{Rails.root}/.pgpass"
    url = "#{config_db['host']}:#{config_db['port']}"
    user = config_db['username']
    db = config_db['database']
    File.open(pg_pass_path, 'w') do |f|
      f.write "#{url}:#{db}:#{user}:#{config_db['password']}"
    end
    change_file_permission(pg_pass_path)
    yield
    File.delete(pg_pass_path)
  end
end
