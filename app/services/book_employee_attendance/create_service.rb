class BookEmployeeAttendance::CreateService < ApplicationService
  def execute_service
    book_employee_attendance = BookEmployeeAttendance.new
    if record_save?(book_employee_attendance)
      render_json(BookEmployeeAttendanceSerializer.new(book_employee_attendance, fields: @fields, include: [:employee]),
                  { status: :created })
    else
      render_error_record(book_employee_attendance)
    end
  end

  def record_save?(book_employee_attendance)
    ApplicationRecord.transaction do
      update_attribute(book_employee_attendance)
      book_employee_attendance.save!
    end
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def update_attribute(book_employee_attendance)
    @table_definition = Datatable::DefinitionExtractor.new(BookEmployeeAttendance)
    @fields = { book_employee_attendance: permitted_column_names(BookEmployeeAttendance, nil) }
    permitted_columns = permitted_edit_columns(BookEmployeeAttendance, @table_definition.allowed_edit_columns)
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(permitted_columns)
    book_employee_attendance.attributes = permitted_params
  end
end
