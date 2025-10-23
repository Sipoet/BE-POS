class BookEmployeeAttendance::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    book_employee_attendance = BookEmployeeAttendance.find(params[:id])
    raise RecordNotFound.new(params[:id], BookEmployeeAttendance.model_name.human) if book_employee_attendance.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(BookEmployeeAttendanceSerializer.new(book_employee_attendance, options))
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(BookEmployeeAttendance)
    allowed_includes = [:book_employee_attendance]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: BookEmployeeAttendance)
  end
end
