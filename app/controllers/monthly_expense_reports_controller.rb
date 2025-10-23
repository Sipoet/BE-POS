class MonthlyExpenseReportsController < ApplicationController
  before_action :authorize_user!
  def index
    run_service_default
  end

  def group_by
    run_service_default
  end
end
