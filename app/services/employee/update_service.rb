class Employee::UpdateService < ApplicationService

  def execute_service
    permitted_column = permitted_column_names(Employee)
    if permitted_column == ALL_COLUMN
      permitted_column = [:code,:name,:role_id,:start_working_date,
      :end_working_date, :description,:payroll_id,
      :id_number,:contact_number, :address, :bank_register_name,
      :marital_status, :tax_number, :religion, :email,
      :bank, :bank_account, :status, :image_code]
    end
    permitted_params = @params.required(:data)
                              .required(:attributes)
                              .permit(*permitted_column)
    employee = Employee.find(params[:id])
    raise RecordNotFound.new(params[:id],Employee.model_name.human) if employee.nil?
    begin
      ApplicationRecord.transaction do
        if permitted_params[:image_code] != employee.image_code && employee.image_code.present?
          FileStore.where(code: employee.image_code).delete_all
        end
        build_schedule(employee)
        build_day_offs(employee)
        if permitted_params[:code].present?
          permitted_params[:code] = permitted_params[:code].try(:downcase)
        end
        employee.update!(permitted_params)
        render_json(EmployeeSerializer.new(employee))
      end
    rescue ActiveRecord::RecordInvalid => e
      render_error_record(employee)
    rescue => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
      render_json({message: e.message},{status: :conflict})
    end
  end

  private

  def build_schedule(employee)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:work_schedules)
                              .permit(data:[:type,:id, attributes:[:shift, :begin_work, :end_work,:day_of_week,:active_week]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    work_schedules = employee.work_schedules.index_by(&:id)
    permitted_params[:data].each do |line_params|
      work_schedule = work_schedules[line_params[:id].to_i]
      if work_schedule.present?
        work_schedule.attributes = line_params[:attributes]
        work_schedules.delete(line_params[:id])
      else
        work_schedule = employee.work_schedules.build(line_params[:attributes])
      end
    end
    work_schedules.values.map(&:mark_for_destruction)
  end

  def build_day_offs(employee)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:employee_day_offs)
                              .permit(data:[:type,:id, attributes:[:day_of_week,:active_week]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    employee_day_offs = employee.employee_day_offs.index_by(&:id)
    permitted_params[:data].each do |line_params|
      employee_day_off = employee_day_offs[line_params[:id].to_i]
      if employee_day_off.present?
        employee_day_off.attributes = line_params[:attributes]
        employee_day_offs.delete(line_params[:id])
      else
        employee_day_off = employee.employee_day_offs.build(line_params[:attributes])
      end
    end
    employee_day_offs.values.map(&:mark_for_destruction)
  end
end
