class Ipos::Item::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    item = Ipos::Item.find_by(code: params[:code])
    if item.nil?
      item_code = Ipos::ItemSellUom.find_by(barcode: params[:code])&.item_code
      item = Ipos::Item.find_by(code: item_code) if item_code.present?
    end
    raise RecordNotFound.new(params[:code], Ipos::Item.model_name.human) if item.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::ItemSerializer.new(item, options))
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::Item)
    allowed_includes = [:item]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::Item)
  end
end
