class PaymentProviderEdc::UpdateService < ApplicationService
  def execute_service
    payment_provider_edc = PaymentProviderEdc.find(params[:id])
    raise RecordNotFound.new(params[:id], PaymentProviderEdc.model_name.human) if payment_provider_edc.nil?

    if record_save?(payment_provider_edc)
      render_json(PaymentProviderEdcSerializer.new(payment_provider_edc, { fields: @fields }))
    else
      render_error_record(payment_provider_edc)
    end
  end

  def record_save?(payment_provider_edc)
    ApplicationRecord.transaction do
      update_attribute(payment_provider_edc)
      payment_provider_edc.save!
    end
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def update_attribute(payment_provider_edc)
    table_definition = Datatable::DefinitionExtractor.new(PaymentProviderEdc)
    allowed_columns = table_definition.column_names
    @fields = { payment_provider_edc: allowed_columns }
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(allowed_columns)
    payment_provider_edc.attributes = permitted_params
  end
end
