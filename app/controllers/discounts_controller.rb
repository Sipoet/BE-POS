class DiscountsController < ApplicationController

  before_action :authenticate_user!

  def index
    run_service_default
  end

  def show
    run_service_default
  end

  def create
    run_service_default
  end

  def update
    run_service_default
  end

  def destroy
    run_service_default
  end

  def refresh_active_promotion
    run_service_default
  end

  def refresh_promotion
    run_service_default
  end

  def refresh_all_promotion
    run_service_default
  end

  def columns
    run_service(Discount::ColumnsService)
  end
end
