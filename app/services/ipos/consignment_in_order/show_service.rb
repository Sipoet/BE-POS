class Ipos::ConsignmentInOrder::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    consignment_in_order = Ipos::ConsignmentInOrder.find(@code)
    raise RecordNotFound.new(@code, Ipos::ConsignmentInOrder.model_name.human) if consignment_in_order.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::ConsignmentInOrderSerializer.new(consignment_in_order, options))
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::ConsignmentInOrder)
    allowed_includes = %i[consignment_in_order purchase_order_items supplier purchase_order_items.item]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::ConsignmentInOrder)
    @code = CGI.unescape(params[:code])
  end
end
