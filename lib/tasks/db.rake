namespace :db do
  desc 'backup db psql'
  task backup: :environment do
    config_db = Rails.configuration.database_configuration[Rails.env]
    host = config_db['host']
    port = config_db['port']
    user = config_db['username']
    db = config_db['database']
    filename = "#{db}_backup_#{Time.now.in_time_zone('Singapore').strftime('%y%m%d%H%M%S'
    )}.dump"
    dir_path = "/backups"
    create_dir(dir_path)
    on_db_scope(config_db) do
      cmd = "pg_dump --host #{host} --port #{port} --username #{user} --verbose --clean --no-owner --no-password --format=c #{db} -f #{dir_path}/#{filename}"
      puts cmd
      system(cmd, exception: true)
    end
    remove_file(dir_path, before_time: 1.month.ago)
  end

  def remove_file(dir_path, before_time: )
    files = []
    Dir["#{dir_path}/*.dump"].each do |file_path|
      file = File.open(file_path,'r')
      next if file.nil?
      files << file
    end
    total_db = files.length
    limit_db = Setting.get('number_of_db_saved') || 50
    files.sort_by{|file| file.ctime}.each do |file|
      if file.ctime <= before_time || total_db > limit_db
        Sidekiq.logger.info "==========DELETE #{file.path}"
        file.close
        File.delete(file.path)
        total_db -= 1
      else
        file.close
      end
    end
  end

  def create_dir(path)
    Dir.mkdir(path) unless Dir.exist?(path)
  end

  def change_file_permission(path)
    FileUtils.chmod 0600, path,verbose: true
  end

  def on_db_scope(config_db)
    pg_pass_path = "#{Rails.root}/.pgpass"
    File.open(pg_pass_path,'w') do |f|
      f.write "#{config_db['host']}:#{config_db['port']}:#{config_db['database']}:#{config_db['username']}:#{config_db['password']}"
    end
    change_file_permission(pg_pass_path)
    yield
    File.delete(pg_pass_path)
  end
end
