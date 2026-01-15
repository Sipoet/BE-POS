class Ipos::Supplier::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    supplier = Ipos::Supplier.find(params[:code])
    raise RecordNotFound.new(params[:code], Ipos::Supplier.model_name.human) if supplier.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::SupplierSerializer.new(supplier, options))
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::Supplier)
    allowed_includes = [:supplier]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::Supplier)
  end
end
