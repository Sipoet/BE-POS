class EmployeeSerializer
  include JSONAPI::Serializer
  attributes :code, :name,:start_working_date,
  :end_working_date, :description, :bank_register_name,
  :id_number,:contact_number, :address, :image_code,
  :bank, :bank_account,:status, :debt, :shift,
  :created_at, :updated_at,:tax_number, :marital_status,
  :religion, :email

  belongs_to :role, if: Proc.new { |record, params| params[:include].include?('role') rescue false }
  belongs_to :payroll, if: Proc.new { |record, params| params[:include].include?('payroll') rescue false }

  has_many :work_schedules, if: Proc.new { |record, params| params[:include].include?('work_schedules') rescue false } do |employee|
    employee.work_schedules.order(shift: :asc, day_of_week: :asc)
  end

  has_many :employee_day_offs, if: Proc.new { |record, params| params[:include].include?('employee_day_offs') rescue false } do |employee|
    employee.employee_day_offs.order(day_of_week: :asc)
  end

end
