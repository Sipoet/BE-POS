class Supplier::ShowService < ApplicationService
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
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Supplier)
    allowed_fields = [:supplier]
    result = dezerialize_table_params(params,
                                      allowed_fields: allowed_fields,
                                      table_definitions: @table_definitions)
    @included = result.included
    @fields = result.fields
  end
end
