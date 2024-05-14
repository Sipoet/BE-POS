class HistoriesController < ApplicationController
  before_action :authenticate_user!

  def index
    run_service_default
  end
end
