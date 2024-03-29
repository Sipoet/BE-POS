class ItemsController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:query].present?
      run_service(Item::OldIndexService)
    else
      run_service_default
    end
  end
end
