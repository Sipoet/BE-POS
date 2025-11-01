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
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::PurchaseReturn)
    allowed_fields = [:purchase_return, :purchase_return_items, 'purchase_return_items.item', :supplier]
    result = dezerialize_table_params(params,
                                      allowed_fields: allowed_fields,
                                      table_definitions: @table_definitions)
    @included = result.included
    @fields = result.fields
    @code = CGI.unescape(params[:code])
  end
end
