class PaymentMethodsController < ApplicationController
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
end
