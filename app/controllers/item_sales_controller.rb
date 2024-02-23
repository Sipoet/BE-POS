class ItemSalesController < ApplicationController
  before_action :authorize_user!

  def transaction_report
    run_service_default
  end

  def period_report
    run_service_default
  end
end
