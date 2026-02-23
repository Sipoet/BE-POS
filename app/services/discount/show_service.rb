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
    allowed_includes = %i[discount_filters
                          customer_group]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Discount)
  end
end
