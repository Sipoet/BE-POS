class Brand::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    brand = Ipos::Brand.find(params[:code])
    raise RecordNotFound.new(params[:code], Ipos::Brand.model_name.human) if brand.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::BrandSerializer.new(brand, options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Brand)
    allowed_fields = [:brand]
    result = dezerialize_table_params(params,
                                      allowed_fields: allowed_fields,
                                      table_definitions: @table_definitions)
    @included = result.included
    @fields = result.fields
  end
end
