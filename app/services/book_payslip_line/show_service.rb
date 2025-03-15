class BookPayslipLine::ShowService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    book_payslip_line = BookPayslipLine.find(params[:id])
    raise RecordNotFound.new(params[:id],BookPayslipLine.model_name.human) if book_payslip_line.nil?
    options = {
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(BookPayslipLineSerializer.new(book_payslip_line,options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(BookPayslipLine)
    allowed_fields = [:book_payslip_line]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      table_definitions: @table_definitions)
    @included = result.included
    @fields = result.fields
  end

end
