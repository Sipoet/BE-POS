class RefreshReportJob < ApplicationJob
  sidekiq_options queue: 'low', retry: false

  def perform(table_key = nil)
    tables = if table_key.present?
               [Setting::VIEW_TABLE_LIST[table_key.to_sym]].flatten.compact
             else
               Setting::VIEW_TABLE_LIST.values.flatten
             end

    tables.each do |table|
      table.constantize.refresh!
    end
  end
end
