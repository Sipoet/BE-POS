class EdcSettlement::CheckEdcService < ApplicationService
  include TransactionReportFinder
  def execute_service
    permitted_params = params.permit(:cashier_session_id)
    cashier_session = CashierSession.find(permitted_params[:cashier_session_id])
    total_in_inputs = grouped_edc_settlement_amount(cashier_session.edc_settlements.includes(:payment_type))
    total_in_systems = grouped_system_amount(cashier_session.date)
    Rails.logger.debug "===#{total_in_systems}"
    results = []
    total_in_systems.each do |payment_type, amount|
      results << EdcSummary.new(
        payment_type_name: payment_type.name,
        payment_type_id: payment_type.id,
        total_in_input: total_in_inputs[payment_type] || 0,
        total_in_system: amount)
    end
    render_json EdcSummarySerializer.new(results)
  end

  private

  def grouped_edc_settlement_amount(edc_settlements)
    edc_settlements.group_by(&:payment_type)
                    .each_with_object({}) do |(payment_type, values),obj|
                      obj[payment_type] = values.sum(&:amount)
                    end
  end

  def grouped_system_amount(date)
    start_time = DateTime.parse("#{Date.today}T07:00:00Z")
    end_time = DateTime.parse("#{Date.tomorrow}T06:59:59Z")
    sales_transaction_report = summary_sales_transaction(start_time:start_time,end_time: end_time)
    PaymentType.all.each_with_object({}) do |payment_type,obj|
      amount = case payment_type.name
      when /(tunai|cash)/i
        sales_transaction_report.cash_total
      when /debit/i
        sales_transaction_report.debit_total
      when /(kredit|credit)/i
        sales_transaction_report.credit_total
      when /qris/i
        sales_transaction_report.qris_total
      when /(online|transfer)/i
        sales_transaction_report.online_total
      else
        0
      end
      obj[payment_type] = amount
    end
  end

  class EdcSummary
    attr_accessor :payment_type_name,
                  :payment_type_id,
                  :total_in_input,
                  :total_in_system
    def initialize(options)
      options.each do |key,value|
        instance_variable_set("@#{key}",value)
      end
    end

    def status
      if total_in_input == total_in_system
        'same'
      elsif total_in_input > total_in_system
        'greated'
      else
        'lesser'
      end
    end
  end
end
