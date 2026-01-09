class PurchaseOrder::ShowService < ApplicationService
  include JsonApiDeserializer

  def execute_service
    extract_params
    purchase_order = Ipos::PurchaseOrder.find(@code)
    raise RecordNotFound.new(@code, Ipos::PurchaseOrder.model_name.human) if purchase_order.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::PurchaseOrderSerializer.new(purchase_order, options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::PurchaseOrder)
    allowed_includes = %i[purchase_order purchase_order_items supplier purchase_order_items.item]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definitions: @table_definitions)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::PurchaseOrder)
    @code = CGI.unescape(params[:code])
  end
end
