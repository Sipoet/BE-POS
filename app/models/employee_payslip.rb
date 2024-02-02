class EmployeePayslip < ApplicationRecord
  enum :status, {
    draft: 0,
    confirmed: 1,
    paid: 2,
    cancelled: 3
  }

  has_many :employee_payslip_lines, dependent: :destroy, inverse_of: :employee_payslip

end
