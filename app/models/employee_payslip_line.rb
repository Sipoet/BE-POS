class EmployeePayslipLine < ApplicationRecord
  enum :group, {
    earning: 0,
    deduction: 1,
  }

  enum :payslip_type, {
    base_salary: 0, #gaji pokok
    incentive: 1, #tunjangan
    insurance: 2,
    debt: 3, #panjar
    commission: 4,
    tax: 5
  }

  belongs_to :employee_payslip, inverse_of: :employee_payslip_lines
end
