class PayslipReport < ApplicationModel

  TABLE_HEADER = [
    datatable_column(self, :employee_name, :link,path:'employees',attribute_key: 'employee_name', sort_key:'employee_name'),
    datatable_column(self, :employee_start_working_date, :date),
    datatable_column(self, :start_date, :date),
    datatable_column(self, :end_date, :date),
    datatable_column(self, :work_days, :integer),
    datatable_column(self, :total_day, :integer),
    datatable_column(self, :overtime_hour, :integer),
    datatable_column(self, :late, :integer),
    datatable_column(self, :sick_leave, :integer),
    datatable_column(self, :known_absence, :integer),
    datatable_column(self, :unknown_absence, :integer),
    datatable_column(self, :base_salary, :decimal),
    datatable_column(self, :overtime_incentive, :decimal),
    datatable_column(self, :positional_incentive, :decimal),
    datatable_column(self, :attendance_incentive, :decimal),
    datatable_column(self, :other_incentive, :decimal),
    datatable_column(self, :debt, :decimal),
    datatable_column(self, :tax_amount, :decimal),
    datatable_column(self, :nett_salary, :decimal)
  ]

  attr_accessor :start_date, :end_date, :employee_id, :employee_name,
                :employee_start_working_date, :debt,:late,:overtime_incentive,
                :total_day, :work_days, :sick_leave, :overtime_hour,
                :known_absence, :unknown_absence, :positional_incentive,
                :attendance_incentive, :base_salary, :tax_amount, :nett_salary,
                :payslip_id, :other_incentive


  def employee
    @employee ||= (employee_id.nil? ? nil : Employee.find(employee_id))
  end

  def payslip
    @payslip ||= (payslip_id.nil? ? nil : Payslip.find(payslip_id))
  end

  def id
    payslip_id
  end
end