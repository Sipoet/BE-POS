class SystemSettingsController < ApplicationController
  before_action :authorize_user!

  def index
    run_service_default
  end

  def show
    run_service_default
  end

  def update
    run_service_default
  end

  def refresh_table
    run_service_default
  end

  def list_tables
    run_service_default
  end
end
