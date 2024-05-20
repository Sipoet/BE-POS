class ActivityLogsController < ApplicationController
  before_action :authenticate_user!

  def index
    run_service_default
  end

  def by_item
    run_service_default
  end

  def by_user
    run_service_default
  end
end
