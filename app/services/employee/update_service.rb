class Employee::UpdateService < ApplicationService

  def execute_service
    permitted_params = @params.required(:data)
                              .required(:attributes)
                              .permit(:name,:role_id,:start_working_date,
                                      :end_working_date, :description,:payroll_id,
                                      :id_number,:contact_number, :address,
                                      :bank, :bank_account, :status, :image_code
                                      )
    employee = Employee.find_by(code: params[:code].to_s)
    raise RecordNotFound.new(params[:code],Employee.model_name.human) if employee.nil?
    begin
      ApplicationRecord.transaction do
        if permitted_params[:image_code] != employee.image_code && employee.image_code.present?
          FileStore.where(code: employee.image_code).delete_all
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


end
