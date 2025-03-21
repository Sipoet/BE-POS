class Item::ShowService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    item = Ipos::Item.find(params[:code])
    raise RecordNotFound.new(params[:code],Ipos::Item.model_name.human) if item.nil?
    options = {
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(ItemSerializer.new(item,options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Item)
    allowed_fields = [:item]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      table_definitions: @table_definitions)
    @included = result.included
    @fields = result.fields
  end

end
