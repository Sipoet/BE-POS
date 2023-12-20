class BackgroundJobsController < ApplicationController
  def index
    run_service_default
  end

  def show
    run_service_default
  end

  def retry
    run_service_default
  end

  def destroy
    run_service_default
  end
end
