class ConsignmentInOrder::ShowService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    consignment_in_order = Ipos::ConsignmentInOrder.find(@code)
    raise RecordNotFound.new(@code,Ipos::ConsignmentInOrder.model_name.human) if consignment_in_order.nil?
    options = {
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(Ipos::ConsignmentInOrderSerializer.new(consignment_in_order,options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::ConsignmentInOrder)
    allowed_fields = [:consignment_in_order,:purchase_order_items,:supplier,:'purchase_order_items.item']
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      table_definitions: @table_definitions)
    @included = result.included
    @fields = result.fields
    @code = CGI.unescape(params[:code])
  end

end
