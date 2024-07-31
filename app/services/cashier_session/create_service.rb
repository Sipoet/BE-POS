class CashierSession::CreateService < ApplicationService

  def execute_service
    cashier_session = CashierSession.new
    if record_save?(cashier_session)
      render_json(CashierSessionSerializer.new(cashier_session,fields:@fields),{status: :created})
    else
      render_error_record(cashier_session)
    end
  end

  def record_save?(cashier_session)
    ApplicationRecord.transaction do
      build_cash_in_session_details(cashier_session)
      build_cash_out_session_details(cashier_session)
      build_edc_settlement(cashier_session)
      update_attribute(cashier_session)
      cashier_session.save!
    end
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  private

  def update_attribute(cashier_session)
    allowed_columns = CashierSession::TABLE_HEADER.map(&:name)
    @fields = {cashier_session: allowed_columns}
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(allowed_columns)
    cashier_session.attributes = permitted_params
    cashier_session.start_time = cashier_session.cash_in_session_details.map(&:start_time).min
    cashier_session.end_time = cashier_session.cash_in_session_details.map(&:end_time).max
    calculate_summary(cashier_session)
  end

  def calculate_summary(cashier_session)
    reset_summary(cashier_session)
    sales = Ipos::Sale.where('tanggal BETWEEN ? AND ?', cashier_session.start_time, cashier_session.end_time)
                      .where(tipe: ['KSR','JL'])
    sales.each do |sale|
      if sale.jmltunai > 0
        cashier_session.total_cash_in += sale.totalakhir
      elsif sale.jmlkk > 0
        cashier_session.total_credit += sale.jmlkk
      elsif sale.jmldebit > 0
        cashier_session.total_debit += sale.jmldebit
      elsif sale.byr_emoney_prod == 'QRIS'
        cashier_session.total_qris += sale.jmlemoney
      elsif sale.byr_emoney_prod == 'online transfer'
        cashier_session.total_transfer += sale.jmlemoney
      else
        cashier_session.total_other_in += sale.totalakhir
      end
    end
  end

  def reset_summary(cashier_session)
    cashier_session.total_cash_in = 0
    cashier_session.total_cash_out = 0
    cashier_session.total_debit = 0
    cashier_session.total_credit = 0
    cashier_session.total_qris = 0
    cashier_session.total_emoney = 0
    cashier_session.total_transfer = 0
    cashier_session.total_other_in = 0
  end

  def build_cash_in_session_details(cashier_session)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:cash_in_session_details)
                              .permit(data:[:type,:id, attributes:[:user_id,:start_time,:end_time,:begin_cash,:cash_in]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    permitted_params[:data].each do |line_params|
      cashier_session.cash_in_session_details.build(line_params[:attributes])
    end
  end

  def build_cash_out_session_details(cashier_session)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:cash_out_session_details)
                              .permit(data:[:type,:id, attributes:[:date,:user_id,:name,:amount,:description]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    permitted_params[:data].each do |line_params|
      cashier_session.cash_out_session_details.build(line_params[:attributes])
    end
  end

  def build_edc_settlement(cashier_session)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:edc_settlements)
                              .permit(data:[:type,:id, attributes:[:terminal_id,:payment_method_id,:merchant_id,:amount, :diff_amount]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    permitted_params[:data].each do |line_params|
      cashier_session.edc_settlements.build(line_params[:attributes])
    end
  end

end
