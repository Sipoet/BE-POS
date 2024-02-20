class Employee::UpdateService < ApplicationService

  def execute_service
    permitted_params = @params.required(:employee)
                              .permit(:name,:role_id,:start_working_date,
                                      :end_working_date, :description,:payroll_id,
                                      :id_number,:contact_number, :address,
                                      :bank, :bank_account, :status
                                      )
    employee = Employee.find_by(code: params[:code].to_s)
    raise RecordNotFound.new(params[:code],Employee.model_name.human) if employee.nil?
    if employee.update(permitted_params)
      render_json(EmployeeSerializer.new(employee),{status: :created})
    else
      render_error_record(employee)
    end
  end

end
