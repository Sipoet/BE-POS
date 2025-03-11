class EmployeeAttendance::UpdateService < ApplicationService

  def execute_service
    employee_attendance = EmployeeAttendance.find(params[:id])
    raise RecordNotFound.new(params[:id],EmployeeAttendance.model_name.human) if employee_attendance.nil?
    if record_save?(employee_attendance)
      render_json(EmployeeAttendanceSerializer.new(employee_attendance,{fields: @fields}))
    else
      render_error_record(employee_attendance)
    end
  end

  def record_save?(employee_attendance)
    ApplicationRecord.transaction do
      update_attribute(employee_attendance)
      employee_attendance.save!
    end
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  def update_attribute(employee_attendance)
    table_definitions = Datatable::DefinitionExtractor.new(EmployeeAttendance)
    allowed_columns = table_definitions.column_names
    @fields = {employee_attendance: allowed_columns}
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(allowed_columns)
    employee_attendance.attributes = permitted_params
  end
end
