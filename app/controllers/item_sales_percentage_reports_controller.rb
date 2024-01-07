class ItemSalesPercentageReportsController < ApplicationController
  before_action do
    authorize_user!(%w{admin})
  end

  def index
    run_service_default
  end

  def columns
    run_service(ItemSalesPercentageReport::ColumnsService)
  end
end
