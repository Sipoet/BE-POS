require 'cgi'
class Sale::ShowService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    sale = Ipos::Sale.find(@code)
    raise RecordNotFound.new(@code, Ipos::Sale.model_name.human) if sale.nil?
    options = {
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(Ipos::SaleSerializer.new(sale, options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Sale)
    allowed_fields = [:sale, :sale_items,'sale_items.item']
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      table_definitions: @table_definitions)
    @included = result.included
    @fields = result.fields
    @code = CGI.unescape(params[:code])
  end

end
