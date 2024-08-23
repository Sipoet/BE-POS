class TransferItemsController < ApplicationController
  before_action :authorize_user!
  def index
    run_service_default
  end
end
