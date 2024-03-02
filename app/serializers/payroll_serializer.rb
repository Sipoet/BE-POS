class PayrollSerializer
  include JSONAPI::Serializer
  attributes :name, :paid_time_off, :description,
  :created_at, :updated_at

  has_many :payroll_lines, if: Proc.new { |record, params| params[:include].include?('payroll_lines') rescue false } do |payroll|
    payroll.payroll_lines.order(row: :asc)
  end

  has_many :work_schedules, if: Proc.new { |record, params| params[:include].include?('work_schedules') rescue false } do |payroll|
    payroll.work_schedules.order(shift: :asc, day_of_week: :asc)
  end

end
