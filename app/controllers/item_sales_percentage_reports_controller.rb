class ItemSalesPercentageReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    run_service_default
  end

  def columns
    run_service(ItemSalesPercentageReport::ColumnsService)
  end
end
