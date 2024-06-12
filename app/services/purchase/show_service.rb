class Purchase::ShowService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    purchase = Purchase.find(params[:id])
    raise RecordNotFound.new(params[:id],Purchase.model_name.human) if purchase.nil?
    options = {
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(PurchaseSerializer.new(purchase,options))
  end

  def extract_params
    allowed_columns = Purchase::TABLE_HEADER.map(&:name)
    allowed_fields = [:purchase, :purchase_items]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      allowed_columns: allowed_columns)
    @included = result.included
    @fields = result.fields
  end

end
