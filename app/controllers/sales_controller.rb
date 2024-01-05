class SalesController < ApplicationController
  before_action :authenticate_user!
  def transaction_report
    run_service_default
  end
end
