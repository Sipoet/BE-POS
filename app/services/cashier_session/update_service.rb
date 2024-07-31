class CashierSession::UpdateService < ApplicationService

  def execute_service
    cashier_session = CashierSession.find(params[:id])
    raise RecordNotFound.new(params[:id],CashierSession.model_name.human) if cashier_session.nil?
    if record_save?(cashier_session)
      render_json(CashierSessionSerializer.new(cashier_session,{fields: @fields}))
    else
      render_error_record(cashier_session)
    end
  end

  def record_save?(cashier_session)
    ApplicationRecord.transaction do
      update_cash_in_session_details(cashier_session)
      update_cash_out_session_details(cashier_session)
      update_edc_settlement(cashier_session)
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

  def update_cash_in_session_details(cashier_session)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:cash_in_session_details)
                              .permit(data:[:type,:id, attributes:[:user_id,:start_time,:end_time,:begin_cash,:cash_in]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    cash_in_session_details = cashier_session.cash_in_session_details.index_by(&:id)
    permitted_params[:data].each do |line_params|
      cash_in_session_detail = cash_in_session_details[line_params[:id].to_i]
      if cash_in_session_detail.present?
        cash_in_session_detail.attributes = line_params[:attributes]
        cash_in_session_details.delete(line_params[:id])
      else
        cash_in_session_detail = cashier_session.cash_in_session_details.build(line_params[:attributes])
      end
    end
    cash_in_session_details.values.map(&:mark_for_destruction)
  end

  def update_cash_out_session_details(cashier_session)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:cash_out_session_details)
                              .permit(data:[:type,:id, attributes:[:date,:user_id,:name,:amount,:description]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    cash_out_session_details = cashier_session.cash_out_session_details.index_by(&:id)
    permitted_params[:data].each do |line_params|
      cash_out_session_detail = cash_out_session_details[line_params[:id].to_i]
      if cash_out_session_detail.present?
        cash_out_session_detail.attributes = line_params[:attributes]
        cash_out_session_details.delete(line_params[:id])
      else
        cash_out_session_detail = cashier_session.cash_out_session_details.build(line_params[:attributes])
      end
    end
    cash_out_session_details.values.map(&:mark_for_destruction)
  end

  def update_edc_settlement(cashier_session)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:edc_settlements)
                              .permit(data:[:type,:id, attributes:[:terminal_id,:payment_method_id,:merchant_id,:amount, :diff_amount]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    edc_settlements = cashier_session.edc_settlements.index_by(&:id)
    permitted_params[:data].each do |line_params|
      edc_settlement = edc_settlements[line_params[:id].to_i]
      if edc_settlement.present?
        edc_settlement.attributes = line_params[:attributes]
        edc_settlements.delete(line_params[:id])
      else
        edc_settlement = cashier_session.edc_settlements.build(line_params[:attributes])
      end
    end
    edc_settlements.values.map(&:mark_for_destruction)
  end

end
