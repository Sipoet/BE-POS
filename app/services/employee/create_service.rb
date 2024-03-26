class Employee::CreateService < ApplicationService

  def execute_service
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(:code, :name,:role_id,:start_working_date,
                                      :end_working_date, :description,:payroll_id,
                                      :id_number,:contact_number, :address,
                                      :bank, :bank_account, :image_code
                                      )
    employee = Employee.new(permitted_params)
    begin
      ApplicationRecord.transaction do
        if permitted_params[:image_code].present?
          FileStore.where(code: permitted_params[:image_code]).update(expired_at: nil)
        end
        employee.generate_code if employee.code.blank?
        employee.code = employee.code.downcase
        build_schedule(employee)
        employee.save!
        render_json(EmployeeSerializer.new(employee),{status: :created})
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
                              .permit(data:[:type,:id, attributes:[:shift, :begin_work, :end_work,:day_of_week, :active_week]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    permitted_params[:data].each do |line_params|
      employee.work_schedules.build(line_params[:attributes])
    end
  end
end
