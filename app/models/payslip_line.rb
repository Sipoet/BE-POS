class PayslipLine < ApplicationRecord
  include PayrollFormula
  has_paper_trail ignore: [:id, :created_at, :updated_at]
  enum :group, {
    earning: 0,
    deduction: 1,
  }

  enum :formula,PAYROLL_FORMULA_LIST

  validates :amount, presence: true, numericality:{greater_than: 0}
  validates :group, presence: true

  belongs_to :payslip, inverse_of: :payslip_lines
  belongs_to :payroll_type, optional: true
  has_one :book_payslip_line, dependent: :nullify
end
