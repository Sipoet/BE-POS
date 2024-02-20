class PayrollSerializer
  include JSONAPI::Serializer
  attributes :name, :paid_time_off, :description

  has_many :payroll_lines do |payroll|
    payroll.payroll_lines.order(row: :asc)
  end

  has_many :work_schedules do |payroll|
    payroll.work_schedules.order(shift: :asc, day_of_week: :asc)
  end

end
