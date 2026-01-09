class PurchaseReturn::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    purchase_return = Ipos::PurchaseReturn.find(@code)
    raise RecordNotFound.new(@code, PurchaseReturn.model_name.human) if purchase_return.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::PurchaseReturnSerializer.new(purchase_return, options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(PurchaseReturn)
    allowed_includes = [:purchase_return, :purchase_return_items, 'purchase_return_items.item', :supplier]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definitions: @table_definitions)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: PurchaseReturn)
    @code = CGI.unescape(params[:code])
  end
end
