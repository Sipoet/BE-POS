class RefreshReportJob < ApplicationJob
  sidekiq_options queue: 'low', retry: false

  def perform(table_key = nil)
    if table_key.present?
      tables =  *SystemSetting::RefreshTableService::TABLE_LIST[table_key.to_sym]
      tables.each do |table|
        table.refresh!
      end
    else
      tables = SystemSetting::RefreshTableService::TABLE_LIST.values.flatten
      tables.each do |table|
        table.refresh!
      end
    end
  end
end
