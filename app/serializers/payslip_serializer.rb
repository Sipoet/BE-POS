class PayslipSerializer
  include JSONAPI::Serializer
  attributes :start_date, :end_date, :payment_time,
              :gross_salary, :notes, :tax_amount,
              :nett_salary, :sick_leave, :work_days,
              :known_absence,:unknown_absence,
              :paid_time_off, :overtime_hour, :late, :status,
              :created_at, :updated_at, :total_day
  belongs_to :payroll
  belongs_to :employee

  has_many :payslip_lines, if: Proc.new { |record, params| params[:include].include?('payslip_lines') rescue false }
end
