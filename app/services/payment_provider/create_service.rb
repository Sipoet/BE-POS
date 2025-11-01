class PaymentProvider::CreateService < ApplicationService
  include NestedAttributesMatchup
  def execute_service
    payment_provider = PaymentProvider.new
    if record_save?(payment_provider)
      options = {
        fields: @fields,
        include: ['payment_provider_edcs'],
        params: { include: ['payment_provider_edcs'] }
      }
      render_json(PaymentProviderSerializer.new(payment_provider, options), { status: :created })
    else
      render_error_record(payment_provider)
    end
  end

  def record_save?(payment_provider)
    ApplicationRecord.transaction do
      update_attribute(payment_provider)
      build_payment_provider_edcs(payment_provider)
      payment_provider.save!
    end
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def build_payment_provider_edcs(payment_provider)
    permitted_params = params.required(:data)
                             .required(:relationships)
                             .required(:payment_provider_edcs)
                             .permit(data: [:type, :id, { attributes: %i[merchant_id terminal_id] }])
    build_attributes(permitted_params[:data], payment_provider.payment_provider_edcs)
  end

  def update_attribute(payment_provider)
    table_definitions = Datatable::DefinitionExtractor.new(PaymentProvider)
    allowed_columns = table_definitions.column_names + [:payment_provider_edcs]
    @fields = { payment_provider: allowed_columns }
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(allowed_columns)
    payment_provider.attributes = permitted_params
  end
end
