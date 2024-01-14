class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:settings]
  def dashboard
    render json: {
      version:'0.0.1'
    }
  end

  def settings
    run_service(Home::SettingService)
  end
end
