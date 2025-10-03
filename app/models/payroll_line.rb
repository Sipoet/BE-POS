class PayrollLine < ApplicationRecord
  include PayrollFormula
  has_paper_trail ignore: [:id, :created_at, :updated_at]

  belongs_to :payroll, inverse_of: :payroll_lines

  validates :group, presence: true
  validates :payroll_type, presence: true
  validates :formula, presence: true
  validates :row, presence: true
  validates :description, presence: true
  belongs_to :payroll_type

  enum :group,{
    earning: 0,
    deduction: 1
  }

  enum :formula,PAYROLL_FORMULA_LIST

  belongs_to :payroll_type, optional: true
end
