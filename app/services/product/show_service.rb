class Product::ShowService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    product = Product.find(params[:id])
    raise RecordNotFound.new(params[:id],Product.model_name.human) if product.nil?
    options = {
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(ProductSerializer.new(product,options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Product)
    allowed_fields = [:product]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      table_definitions: @table_definitions)
    @included = result.included
    @fields = result.fields
  end

end
