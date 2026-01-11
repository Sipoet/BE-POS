class PaymentType::UpdateService < ApplicationService
  def execute_service
    payment_type = PaymentType.find(params[:id])
    raise RecordNotFound.new(params[:id], PaymentType.model_name.human) if payment_type.nil?

    if record_save?(payment_type)
      render_json(PaymentTypeSerializer.new(payment_type, { fields: @fields }))
    else
      render_error_record(payment_type)
    end
  end

  def record_save?(payment_type)
    ApplicationRecord.transaction do
      update_attribute(payment_type)
      payment_type.save!
    end
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def update_attribute(payment_type)
    table_definition = Datatable::DefinitionExtractor.new(PaymentType)
    allowed_columns = table_definition.column_names
    @fields = { payment_type: allowed_columns }
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(allowed_columns)
    payment_type.attributes = permitted_params
  end
end
