class RefreshReportJob < ApplicationJob
  sidekiq_options queue: 'low', retry: false

  def perform
    PurchaseReport.refresh!
    ItemReport.refresh!
    ItemMovement.refresh!
    ItemSalesPerformanceReport.refresh!
    DaySalesPerformanceReport.refresh!
    YearSalesPerformanceReport.refresh!
    MonthSalesPerformanceReport.refresh!
    WeekSalesPerformanceReport.refresh!
  end
end
