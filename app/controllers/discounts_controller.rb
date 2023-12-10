class DiscountsController < ApplicationController

  before_action :authenticate_user!

  def index
    run_service_default(self)
  end

  def show
    run_service_default(self)
  end

  def create
    run_service_default(self)
  end

  def update
    run_service_default(self)
  end

  def destroy
    run_service_default(self)
  end

  def refresh_item_promotion
    run_service_default(self)
  end
end
