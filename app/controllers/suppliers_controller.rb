class SuppliersController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:query].present?
      run_service(Supplier::OldIndexService)
    else
      run_service_default
    end
  end

  def show
    run_service_default
  end
end
