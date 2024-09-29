class PayslipReportSerializer
  include JSONAPI::Serializer
  attributes :start_date, :end_date,
            :nett_salary,
            :sick_leave, :known_absence,
            :unknown_absence, :overtime_hour,
            :work_days,
            :total_day, :employee_id, :employee_name,
            :employee_start_working_date,
            :bank, :bank_account,:bank_register_name, :description,
            :late

  attribute :payroll_type_amounts do |obj, params|
    payroll_types = params[:payroll_types] || []
    payroll_types.each_with_object({}) do |payroll_type,value|
      value[payroll_type.id.to_s] = obj[payroll_type.id].to_d
    end
  end

  belongs_to :employee, if: Proc.new { |record, params| params[:include].include?('employee') rescue false }
  belongs_to :payslip, if: Proc.new { |record, params| params[:include].include?('payslip') rescue false }
end
