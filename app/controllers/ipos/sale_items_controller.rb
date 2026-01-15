class Ipos::SaleItemsController < ApplicationController
  before_action :authorize_user!

  def index
    run_service_default
  end

  def transaction_report
    run_service_default
  end

  def period_report
    run_service_default
  end
end
