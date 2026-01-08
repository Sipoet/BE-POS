class Employee::UpdateService < ApplicationService
  include NestedAttributesMatchup
  def execute_service
    permitted_column = permitted_column_names(Employee, %i[code name role_id start_working_date
                                                           end_working_date description payroll_id user_code
                                                           id_number contact_number address bank_register_name
                                                           marital_status tax_number religion email
                                                           bank bank_account status image_code])

    permitted_params = @params.required(:data)
                              .required(:attributes)
                              .permit(*permitted_column)
    employee = Employee.find(params[:id])
    raise RecordNotFound.new(params[:id], Employee.model_name.human) if employee.nil?

    begin
      ApplicationRecord.transaction do
        if permitted_params[:image_code] != employee.image_code && employee.image_code.present?
          FileStore.where(code: employee.image_code).delete_all
        end
        build_schedule(employee)
        build_day_offs(employee)
        permitted_params[:code] = permitted_params[:code].try(:downcase) if permitted_params[:code].present?
        employee.update!(permitted_params)
        render_json(EmployeeSerializer.new(employee))
      end
    rescue ActiveRecord::RecordInvalid
      render_error_record(employee)
    rescue StandardError => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
      render_json({ message: e.message }, { status: :conflict })
    end
  end

  private

  def build_schedule(employee)
    permitted_params = params.required(:data)
                             .required(:relationships)
                             .required(:work_schedules)
                             .permit(data: [:type, :id, {
                                       attributes: %i[shift begin_work end_work day_of_week active_week]
                                     }])
    return if permitted_params.blank? || permitted_params[:data].blank?

    edit_attributes(permitted_params[:data], employee.work_schedules)
  end

  def build_day_offs(employee)
    permitted_params = params.required(:data)
                             .required(:relationships)
                             .required(:employee_day_offs)
                             .permit(data: [:type, :id, { attributes: %i[day_of_week active_week] }])

    return if permitted_params.blank? || permitted_params[:data].blank?

    edit_attributes(permitted_params[:data], employee.employee_day_offs)
  end
end
