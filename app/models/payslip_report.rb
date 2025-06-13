class PayslipReport < ApplicationModel

  attr_accessor :start_date, :end_date, :employee_id, :employee_name,
                :employee_start_working_date, :debt,:late,
                :total_day, :work_days, :sick_leave, :overtime_hour,
                :known_absence, :unknown_absence, :nett_salary,
                :payslip_id, :bank, :bank_account, :payslip_status,
                :employee_status,
                :bank_register_name, :description, :payroll_type_amounts


  def employee
    @employee ||= (employee_id.nil? ? nil : Employee.find(employee_id))
  end

  def payslip
    @payslip ||= (payslip_id.nil? ? nil : Payslip.find(payslip_id))
  end

  def id
    payslip_id
  end

  def [](key)
    key = key.to_s
    return self.try(key) if self.respond_to?(key)
    @payroll_type_amounts[key]
  end
end
