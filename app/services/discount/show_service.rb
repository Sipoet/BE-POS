class Discount::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    discount = Discount.find_by(id: @params[:id])
    raise ApplicationService::RecordNotFound.new(@params[:id], Discount.name) if discount.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(DiscountSerializer.new(discount, options))
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Discount)
    allowed_includes = [:discount_brands, :discount_item_types, :discount_items,
                        :customer_group, :discount_suppliers,
                        'discount_brands.brand', 'discount_item_types.item_type',
                        'discount_items.item', 'discount_suppliers.supplier']
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Discount)
  end
end
