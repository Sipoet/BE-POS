class PaymentProvider::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    payment_provider = PaymentProvider.find(params[:id])
    raise RecordNotFound.new(params[:id], PaymentProvider.model_name.human) if payment_provider.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    Rails.logger.debug options
    render_json(PaymentProviderSerializer.new(payment_provider, options))
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(PaymentProvider)
    allowed_includes = %i[payment_provider payment_provider_edcs]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: PaymentProvider)
  end
end
