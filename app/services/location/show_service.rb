class Location::ShowService < ApplicationService
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
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Location)
    allowed_fields = [:location]
    result = dezerialize_table_params(params,
                                      allowed_fields: allowed_fields,
                                      table_definitions: @table_definitions)
    @included = result.included
    @fields = result.fields
  end
end
