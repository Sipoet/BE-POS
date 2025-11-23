# frozen_string_literal: true

class SalesController < ApplicationController
  before_action :authorize_user!

  def index
    run_service_default
  end

  def show
    run_service_default
  end

  def report
    run_service_default
  end

  def transaction_report
    run_service_default
  end

  def daily_transaction_report
    run_service_default
  end
end
