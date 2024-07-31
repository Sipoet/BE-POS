class EmployeeAttendancesController < ApplicationController
  before_action :authorize_user!

  def index
    run_service_default
  end

  def update
    run_service_default
  end

  def destroy
    run_service_default
  end

  def mass_upload
    run_service_default
  end

  def mass_update_allow_overtime
    run_service_default
  end
end
