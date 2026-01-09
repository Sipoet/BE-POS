class ItemType::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    item_type = Ipos::ItemType.find(params[:code])
    raise RecordNotFound.new(params[:code], Ipos::ItemType.model_name.human) if item_type.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::ItemTypeSerializer.new(item_type, options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::ItemType)
    allowed_includes = [:item_type]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definitions: @table_definitions)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::ItemType)
  end
end
