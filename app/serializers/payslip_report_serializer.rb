class PayslipReportSerializer
  include JSONAPI::Serializer
  attributes :start_date, :end_date,
              :nett_salary, :base_salary,
              :sick_leave, :known_absence,
              :unknown_absence, :overtime_hour,
              :work_days, :tax_amount, :positional_incentive,
              :attendance_incentive, :other_incentive,
              :total_day, :employee_id, :employee_name,
              :overtime_incentive, :debt, :employee_start_working_date,
              :bank,:bank_account,:bank_register_name, :description
  belongs_to :employee, if: Proc.new { |record, params| params[:include].include?('employee') rescue false }
  belongs_to :payslip, if: Proc.new { |record, params| params[:include].include?('payslip') rescue false }
end
