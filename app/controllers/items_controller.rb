class ItemsController < ApplicationController
  before_action :authenticate_user!

  def index
    run_service_default
  end

  def show
    run_service_default
  end

  def update
    run_service_default
  end

  def with_discount
    run_service_default
  end
end
