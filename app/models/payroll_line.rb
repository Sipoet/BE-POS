class PayrollLine < ApplicationRecord
  include PayrollFormula
  has_paper_trail ignore: %i[id created_at updated_at]

  belongs_to :payroll, inverse_of: :payroll_lines
  belongs_to :payroll_type

  validates :group, presence: true
  validates :payroll_type, presence: true
  validates :formula, presence: true
  validates :row, presence: true
  validates :description, presence: true

  enum :group, {
    earning: 0,
    deduction: 1
  }

  enum :formula, PAYROLL_FORMULA_LIST

  belongs_to :payroll_type, optional: true
end
