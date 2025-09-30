class SupplierSalesPerformanceReportsController < ApplicationController
  def compare
    run_service_default
  end

  def group_by_brand
    run_service_default
  end

  def group_by_item_type
    run_service_default
  end
end
