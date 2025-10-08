class RefreshReportJob < ApplicationJob
  sidekiq_options queue: 'low', retry: false

  def perform
    tables = SystemSetting::RefreshTableService::TABLE_LIST.values.flatten
    tables.each do |table|
      table.refresh!
    end
  end
end
