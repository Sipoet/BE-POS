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

  def update_price
    run_service_default
  end
end
