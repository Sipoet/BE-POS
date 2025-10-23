class BookPayslipLine::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    book_payslip_line = BookPayslipLine.find(params[:id])
    raise RecordNotFound.new(params[:id], BookPayslipLine.model_name.human) if book_payslip_line.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(BookPayslipLineSerializer.new(book_payslip_line, options))
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(BookPayslipLine)
    allowed_includes = [:book_payslip_line]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: BookPayslipLine)
  end
end
