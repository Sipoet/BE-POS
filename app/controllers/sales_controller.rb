class SalesController < ApplicationController
  before_action :authorize_user!

  def transaction_report
    run_service_default
  end
end
