class EmployeeLeave::UpdateService < ApplicationService

  def execute_service
    employee_leave = EmployeeLeave.find(id: params[:id])
    raise RecordNotFound.new(params[:id],EmployeeLeave.model_name.human) if employee_leave.nil?
    if record_save?(employee_leave)
      render_json({message: "#{employee_leave.name} sukses dihapus"})
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
    Rails.logger.errors e.message
    Rails.logger.errors e.backtrace
    return false
  end

  def update_attribute(employee_leave)
    allowed_columns = EmployeeLeave::TABLE_HEADER.map(&:key)
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(allowed_columns)
    employee_leave.attributes = permitted_params
  end
end
