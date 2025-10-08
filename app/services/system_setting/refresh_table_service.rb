class SystemSetting::RefreshTableService < ApplicationService
  TABLE_LIST = {
    purchase_report: PurchaseReport,
    item_report: ItemReport,
    item_sales_performance_report: [
      ItemSalesPerformanceReport,
      ItemMovement,
      DaySalesPerformanceReport,
      YearSalesPerformanceReport,
      MonthSalesPerformanceReport,
      WeekSalesPerformanceReport
    ]
  }

  def execute_service
    permitted_params = params.permit(:table_key)
    list_table = *TABLE_LIST[permitted_params[:table_key]&.to_sym]
    if list_table.blank?
      raise 'invalid table'
    end
    RefreshReportJob.perform_async(permitted_params[:table_key])
    render_json({message: 'refresh in progress'})
  end

end
