class Ipos::UsersController < ApplicationController
  before_action :authorize_user!

  def index
    run_service_default
  end
end
