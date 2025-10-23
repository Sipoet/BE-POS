class UsersController < ApplicationController
  before_action :authorize_user!, only: %i[index create destroy]
  before_action :authorize_if_current_user!, only: %i[show update]
  def index
    run_service_default
  end

  def show
    if params[:username] == current_user.username
      authenticate_user!
    else
      authorize_user!
    end
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

  def unlock_access
    run_service_default
  end

  private

  def authorize_if_current_user!
    if params[:username] == current_user.username
      authenticate_user!
    else
      authorize_user!
    end
  end
end
