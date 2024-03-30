class PayslipsController < ApplicationController
  before_action :authorize_user!

  def index
    run_service_default
  end

  def update
    run_service_default
  end

  def show
    run_service_default
  end

  def destroy
    run_service_default
  end

  def confirm
    run_service_default
  end

  def pay
    run_service_default
  end

  def cancel
    run_service_default
  end

  def report
    run_service_default
  end

  def generate_payslip
    run_service_default
  end
end
