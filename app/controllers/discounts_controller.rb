class DiscountsController < ApplicationController

  before_action :authorize_user!

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

  def delete_inactive_past_discount
    run_service_default
  end

  def template_mass_upload_excel
    run_service_default
  end

  def columns
    run_service(Discount::ColumnsService)
  end
end
