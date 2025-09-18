class BrandSalesPerformanceReportsController < ApplicationController
  def compare
    run_service_default
  end

  def group_by_supplier
    run_service_default
  end

  def group_by_item_type
    run_service_default
  end
end
