class Purchase::ShowService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    purchase = Ipos::Purchase.find(@code)
    raise RecordNotFound.new(@code,Ipos::Purchase.model_name.human) if purchase.nil?
    options = {
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(Ipos::PurchaseSerializer.new(purchase,options))
  end

  def extract_params
    allowed_columns = Ipos::Purchase::TABLE_HEADER.map(&:name)
    allowed_fields = [:purchase, :purchase_items,'purchase_items.item']
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      allowed_columns: allowed_columns)
    @included = result.included
    @fields = result.fields
    @code = CGI.unescape(params[:code])
  end

end
