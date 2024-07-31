class EdcSettlement::UpdateService < ApplicationService

  def execute_service
    edc_settlement = EdcSettlement.find(params[:id])
    raise RecordNotFound.new(params[:id],EdcSettlement.model_name.human) if edc_settlement.nil?
    if record_save?(edc_settlement)
      render_json(EdcSettlementSerializer.new(edc_settlement,{fields: @fields}))
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
    allowed_columns = EdcSettlement::TABLE_HEADER.map(&:name)
    @fields = {edc_settlement: allowed_columns}
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(allowed_columns)
    edc_settlement.attributes = permitted_params
  end
end
