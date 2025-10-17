class SystemSetting::ListTableService < ApplicationService

  def execute_service
    cache = Cache.get('view_table_list')
    if cache.present?
      render_json(cache)
      return
    end
    tables = SystemSetting::RefreshTableService::TABLE_LIST.keys.to_a
    data = {
      data: tables.map do|table|
        {
          value: table,
          label: table.to_s.humanize,
          id: table,
        }
      end
    }
    render_json(data)
    cache = Cache.set('view_table_list',data.to_json, expire: 1.hour)
  end

end
