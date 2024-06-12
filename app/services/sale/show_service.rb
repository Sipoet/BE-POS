class Sale::ShowService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    sale = Sale.find(params[:id])
    raise RecordNotFound.new(params[:id],Sale.model_name.human) if sale.nil?
    options = {
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(SaleSerializer.new(sale,options))
  end

  def extract_params
    allowed_columns = Sale::TABLE_HEADER.map(&:name)
    allowed_fields = [:sale, :sale_items]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      allowed_columns: allowed_columns)
    @included = result.included
    @fields = result.fields
  end

end
