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
    allowed_includes = [:brand]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definitions: @table_definitions)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::Brand)
  end
end
