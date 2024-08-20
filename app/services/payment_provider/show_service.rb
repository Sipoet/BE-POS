class PaymentProvider::ShowService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    payment_provider = PaymentProvider.find(params[:id])
    raise RecordNotFound.new(params[:id],PaymentProvider.model_name.human) if payment_provider.nil?
    options = {
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    Rails.logger.debug options
    render_json(PaymentProviderSerializer.new(payment_provider,options))
  end

  def extract_params
    allowed_columns = PaymentProvider::TABLE_HEADER.map(&:name)
    allowed_fields = [:payment_provider, :payment_provider_edcs]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      allowed_columns: allowed_columns)
    @included = result.included
    @fields = result.fields
  end

end
