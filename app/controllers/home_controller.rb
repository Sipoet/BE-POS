class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:settings]
  def dashboard
    render json: {
      version: $APP_VERSION
    }
  end

  def settings
    run_service(Home::SettingService)
  end

  def check_update
    run_service_default
  end

  def download_app
    run_service_default
  end

end
