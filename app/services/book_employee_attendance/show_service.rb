class BookEmployeeAttendance::ShowService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    book_employee_attendance = BookEmployeeAttendance.find(params[:id])
    raise RecordNotFound.new(params[:id],BookEmployeeAttendance.model_name.human) if book_employee_attendance.nil?
    options = {
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(BookEmployeeAttendanceSerializer.new(book_employee_attendance,options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(BookEmployeeAttendance)
    allowed_fields = [:book_employee_attendance]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      table_definitions: @table_definitions)
    @included = result.included
    @fields = result.fields
  end

end
