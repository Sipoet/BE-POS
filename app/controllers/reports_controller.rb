class ReportsController < ApplicationController
  include ActionController::Live
  def item_sales_percentage
    run_service_default(self)
  end
end
