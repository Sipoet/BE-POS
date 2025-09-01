class RefreshReportJob < ApplicationJob
  sidekiq_options queue: 'low', retry: false

  def perform
    PurchaseReport.refresh!
    ItemReport.refresh!
  end
end
