class ItemSalesController < ApplicationController
  before_action do
    authorize_user!(%w{admin})
  end

  def transaction_report
    run_service_default
  end

  def period_report
    run_service_default
  end
end
