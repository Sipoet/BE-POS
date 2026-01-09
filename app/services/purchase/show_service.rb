class Purchase::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    purchase = Ipos::Purchase.find(@code)
    raise RecordNotFound.new(@code, Ipos::Purchase.model_name.human) if purchase.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::PurchaseSerializer.new(purchase, options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Purchase)
    allowed_includes = [:purchase, :purchase_items, 'purchase_items.item', :supplier, 'purchase_items.item_report']
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definitions: @table_definitions)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::Purchase)
    @code = CGI.unescape(params[:code])
  end
end
