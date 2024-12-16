class Discount::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    discount = Discount.find_by(id: @params[:id])
    raise ApplicationService::RecordNotFound.new(@params[:id],Discount.name) if discount.nil?
    options = {
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(DiscountSerializer.new(discount,options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Discount)
    allowed_fields = [:discount_brands, :discount_item_types, :discount_items,:discount_suppliers,'discount_brands.brand', 'discount_item_types.item_type', 'discount_items.item','discount_suppliers.supplier']
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      table_definitions: @table_definitions)
    @included = result.included
    @fields = result.fields
  end
end
