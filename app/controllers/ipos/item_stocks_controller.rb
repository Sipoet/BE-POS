class Ipos::ItemStocksController < ApplicationController
  before_action :authorize_user!

  def index
    run_service_default
  end

  def update
    run_service_default
  end

  def download_racksheets
    run_service_default
  end

  def upload_racksheets
    run_service_default
  end
end
