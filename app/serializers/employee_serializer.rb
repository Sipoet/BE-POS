class EmployeeSerializer
  include JSONAPI::Serializer
  attributes :code, :name, :start_working_date,
             :end_working_date, :description, :bank_register_name,
             :id_number, :contact_number, :address, :image_code,
             :bank, :bank_account, :status, :debt, :shift,
             :created_at, :updated_at, :tax_number, :marital_status,
             :religion, :email, :user_code

  belongs_to :role, if: proc { |_record, params|
    begin
      params[:include].include?('role')
    rescue StandardError
      false
    end
  }
  belongs_to :payroll, if: proc { |_record, params|
    begin
      params[:include].include?('payroll')
    rescue StandardError
      false
    end
  }

  has_many :work_schedules, if: proc { |_record, params|
    begin
      params[:include].include?('work_schedules')
    rescue StandardError
      false
    end
  } do |employee|
    employee.work_schedules.order(shift: :asc, day_of_week: :asc)
  end

  has_many :employee_day_offs, if: proc { |_record, params|
    begin
      params[:include].include?('employee_day_offs')
    rescue StandardError
      false
    end
  } do |employee|
    employee.employee_day_offs.order(day_of_week: :asc)
  end
end
