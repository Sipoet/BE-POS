class EdcSettlement::CreateService < ApplicationService

  def execute_service
    edc_settlement = EdcSettlement.new
    if record_save?(edc_settlement)
      options = {
        fields: @fields,
        include: [:payment_provider, :payment_type, :cashier_session],
        params:{include: [:payment_provider, :payment_type, :cashier_session]}
      }
      render_json(EdcSettlementSerializer.new(edc_settlement,options),{status: :created})
    else
      render_error_record(edc_settlement)
    end
  end

  def record_save?(edc_settlement)
    ApplicationRecord.transaction do
      update_attribute(edc_settlement)
      edc_settlement.save!
    end
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  def update_attribute(edc_settlement)
    table_definitions = Datatable::DefinitionExtractor.new(EdcSettlement)
    allowed_columns = table_definitions.column_names + [:payment_provider, :payment_type, :cashier_session]
    @fields = {edc_settlement: allowed_columns}
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(allowed_columns)
    edc_settlement.attributes = permitted_params
  end
end
