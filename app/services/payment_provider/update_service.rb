class PaymentProvider::UpdateService < ApplicationService
  include NestedAttributesMatchup
  def execute_service
    payment_provider = PaymentProvider.find(params[:id])
    raise RecordNotFound.new(params[:id], PaymentProvider.model_name.human) if payment_provider.nil?

    if record_save?(payment_provider)
      options = {
        fields: @fields,
        include: ['payment_provider_edcs'],
        params: { include: ['payment_provider_edcs'] }
      }
      render_json(PaymentProviderSerializer.new(payment_provider, options))
    else
      render_error_record(payment_provider)
    end
  end

  def record_save?(payment_provider)
    ApplicationRecord.transaction do
      edit_attribute(payment_provider)
      edit_payment_provider_edcs(payment_provider)
      payment_provider.save!
    end
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def edit_payment_provider_edcs(payment_provider)
    permitted_params = params.required(:data)
                             .required(:relationships)
                             .required(:payment_provider_edcs)
                             .permit(data: [:type, :id, { attributes: %i[merchant_id terminal_id] }])
    edit_attributes(permitted_params[:data], payment_provider.payment_provider_edcs)
  end

  def edit_attribute(payment_provider)
    table_definitions = Datatable::DefinitionExtractor.new(EdcSettlement)
    allowed_columns = table_definitions.column_names + [:payment_provider_edcs]
    @fields = { payment_provider: allowed_columns }
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(allowed_columns)
    payment_provider.attributes = permitted_params
  end
end
