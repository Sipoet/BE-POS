class PayslipLine < ApplicationRecord
  has_paper_trail ignore: [:created_at, :updated_at]
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
  validates :amount, presence: true, numericality:{greater_than: 0}
  validates :group, presence: true

  belongs_to :payslip, inverse_of: :payslip_lines
end
