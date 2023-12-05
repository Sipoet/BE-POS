class ReportsController < ApplicationController
  before_action :authenticate_user!

  include ActionController::Live
  def item_sales_percentage
    run_service_default(self)
  end
end
