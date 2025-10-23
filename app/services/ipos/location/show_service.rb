class Ipos::Location::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    location = Ipos::Location.find(params[:id])
    raise RecordNotFound.new(params[:id], Ipos::Location.model_name.human) if location.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::LocationSerializer.new(location, options))
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::Location)
    allowed_includes = [:location]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::Location)
  end
end
