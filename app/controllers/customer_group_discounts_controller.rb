class CustomerGroupDiscountsController < ApplicationController

  before_action :authorize_user!

  def index
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

  def toggle_discount
    ToggleCustomerGroupDiscountJob.perform_async
    head :no_content
  end
end
