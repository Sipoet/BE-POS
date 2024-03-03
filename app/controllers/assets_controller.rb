class AssetsController < ApplicationController
  before_action :authenticate_user!

  def show
    run_service_default
  end

  def create
    run_service_default
  end
end
