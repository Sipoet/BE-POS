class Employee::CreateService < ApplicationService

  def execute_service
    permitted_params = @params.required(:employee)
                              .permit(:code, :name,:role_id,:start_working_date,
                                      :end_working_date, :description,
                                      :id_number,:contact_number, :address,
                                      :bank, :bank_account
                                      )
    employee = Employee.new(permitted_params)
    employee.generate_code if employee.code.blank?
    if employee.save
      render_json(EmployeeSerializer.new(employee),{status: :created})
    else
      render_error_record(employee)
    end
  end

end
