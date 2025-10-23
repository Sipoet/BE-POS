require 'cgi'
class Ipos::Sale::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    sale = Ipos::Sale.find(@code)
    raise RecordNotFound.new(@code, Ipos::Sale.model_name.human) if sale.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::SaleSerializer.new(sale, options))
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::Sale)
    allowed_includes = [:sale, :sale_items, 'sale_items.item']
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::Item)
    @code = CGI.unescape(params[:code])
  end
end
