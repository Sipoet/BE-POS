class EmployeeLeave::CreateService < ApplicationService

  def execute_service
    employee_leave = EmployeeLeave.new
    if record_save?(employee_leave)
      render_json(EmployeeLeaveSerializer.new(employee_leave),{status: :created})
    else
      render_error_record(employee_leave)
    end
  end

  def record_save?(employee_leave)
    ApplicationRecord.transaction do
      update_attribute(employee_leave)
      employee_leave.save!
    end
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  def update_attribute(employee_leave)
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(:date,:description,:leave_type, :employee_id,:change_date,:change_shift)
    employee_leave.attributes = permitted_params
  end
end
