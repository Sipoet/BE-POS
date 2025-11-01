class ConsignmentIn::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    consignment_in = Ipos::ConsignmentIn.find(@code)
    raise RecordNotFound.new(@code, Ipos::ConsignmentIn.model_name.human) if consignment_in.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::ConsignmentInSerializer.new(consignment_in, options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Purchase)
    allowed_fields = [:consignment_in, :purchase_items, 'purchase_items.item', :supplier, 'purchase_items.item_report']
    result = dezerialize_table_params(params,
                                      allowed_fields: allowed_fields,
                                      table_definitions: @table_definitions)
    @included = result.included
    @fields = result.fields
    @code = CGI.unescape(params[:code])
  end
end
