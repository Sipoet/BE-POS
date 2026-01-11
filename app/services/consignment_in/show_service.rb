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
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::Purchase)
    allowed_includes = [:consignment_in, :purchase_items, 'purchase_items.item', :supplier,
                        'purchase_items.item_report']
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::Purchase)
    @code = CGI.unescape(params[:code])
  end
end
