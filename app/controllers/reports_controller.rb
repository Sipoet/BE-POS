class ReportsController < ApplicationController

  def item_sales_percentage
    run_service_default(self)
  end
end
