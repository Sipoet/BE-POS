class CashierSession::UpdateService < ApplicationService
  include NestedAttributesMatchup
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
      calculate_summary(cashier_session)
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
  end

  def calculate_summary(cashier_session)
    cashier_session.total_in = Ipos::Sale.where('tanggal BETWEEN ? AND ?', cashier_session.start_time, cashier_session.end_time)
                                          .where(tipe: ['KSR','JL'])
                                          .sum(:totalakhir)
    codes = Ipos::CashDrawer.where(wkt_mulai: ..(cashier_session.end_time),wkt_akhir: cashier_session.start_time..)
                            .pluck(:notransaksi)
    cashier_session.total_out = Ipos::CashOut.where(notransaksi: codes).sum(:kas_keluar)
  end

  def update_cash_in_session_details(cashier_session)
    permitted_params = params.required(:data)
                              .required(:relationships)

    return if permitted_params[:cash_in_session_details].blank?
    permitted_params = permitted_params.required(:cash_in_session_details)
                              .permit(data:[:type,:id, attributes:[:user_id,:start_time,:end_time,:begin_cash,:cash_in]])
    edit_attributes(permitted_params[:data], cashier_session.cash_in_session_details)
  end

  def update_cash_out_session_details(cashier_session)
    permitted_params = params.required(:data)
                              .required(:relationships)
    return if permitted_params[:cash_out_session_details].blank?
    permitted_params = permitted_params.required(:cash_out_session_details)
                              .permit(data:[:type,:id, attributes:[:date,:user_id,:name,:amount,:description]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    edit_attributes(permitted_params[:data], cashier_session.cash_out_session_details)
  end

  def update_edc_settlement(cashier_session)
    permitted_params = params.required(:data)
                              .required(:relationships)
    return if permitted_params[:edc_settlements].blank?
    permitted_params = permitted_params.required(:edc_settlements)
                              .permit(data:[:type,:id, attributes:[:terminal_id,:payment_provider_id,:payment_type_id,:merchant_id,:amount]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    edit_attributes(permitted_params[:data], cashier_session.edc_settlements)
    cashier_session.edc_settlements.each{|edc_settlement|edc_settlement.diff_amount =0}
  end

end
