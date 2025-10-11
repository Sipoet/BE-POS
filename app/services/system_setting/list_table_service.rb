class SystemSetting::ListTableService < ApplicationService

  def execute_service
    tables = SystemSetting::RefreshTableService::TABLE_LIST.keys.to_a
    render_json({
      data: tables.map do|table|
        {
          value: table,
          label: table.to_s.humanize,
          id: table,
        }
      end
    })
  end

end
