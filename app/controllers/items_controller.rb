class ItemsController < ApplicationController
  def index
    run_service_default(self)
  end
end