class SystemSetting::RefreshTableService < ApplicationService
  def execute_service
    permitted_params = params.permit(:table_key)
    list_table = Setting::VIEW_TABLE_LIST[permitted_params[:table_key]&.to_sym]
    raise 'invalid table' if list_table.blank?

    RefreshReportJob.perform_async(permitted_params[:table_key])
    render_json({ message: 'refresh in progress' })
  end
end
