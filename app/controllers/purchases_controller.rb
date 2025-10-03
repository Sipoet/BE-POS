class PurchasesController < ApplicationController
  before_action :authorize_user!
  def index
    run_service_default
  end

  def show
    run_service_default
  end

  def report
    run_service_default
  end

  def refresh_report
    PurchaseReport.refresh!
    head :no_content
  end

  def update_price
    run_service_default
  end

  def generate_counterbill
    run_service_default
  end
end
