class Holiday::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    holiday = Holiday.find(params[:id])
    raise RecordNotFound.new(params[:id], Holiday.model_name.human) if holiday.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(HolidaySerializer.new(holiday, options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Holiday)
    allowed_includes = [:holiday]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definitions: @table_definitions)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Holiday)
  end
end
