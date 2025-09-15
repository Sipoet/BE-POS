class ItemSalesPerformanceReportsController < ApplicationController
  before_action :authorize_user!

  def index
    run_service_default
  end

  def supplier
    run_service_default
  end

  def item_type
    run_service_default
  end

  def brand
    run_service_default
  end
end
