class PaymentMethod::UpdateService < ApplicationService
  def execute_service
    payment_method = PaymentMethod.find(params[:id])
    raise RecordNotFound.new(params[:id], PaymentMethod.model_name.human) if payment_method.nil?

    if record_save?(payment_method)
      render_json(PaymentMethodSerializer.new(payment_method, { fields: @fields }))
    else
      render_error_record(payment_method)
    end
  end

  def record_save?(payment_method)
    ApplicationRecord.transaction do
      update_attribute(payment_method)
      payment_method.save!
    end
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def update_attribute(payment_method)
    table_definition = Datatable::DefinitionExtractor.new(PaymentMethod)
    allowed_columns = table_definition.column_names
    @fields = { payment_method: allowed_columns }
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(allowed_columns)
    payment_method.attributes = permitted_params
  end
end
