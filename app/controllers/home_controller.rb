class HomeController < ApplicationController
  before_action :authenticate_user!
  def dashboard
    render json: {
      version:'0.0.1'
    }
  end
end
