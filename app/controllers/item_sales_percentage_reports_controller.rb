class ItemSalesPercentageReportsController < ApplicationController
  before_action :authorize_user!

  def index
    run_service_default
  end

  def group_by_supplier
    run_service_default
  end

  def grouped_report
    run_service_default
  end

  def columns
    run_service(ItemSalesPercentageReport::ColumnsService)
  end
end
