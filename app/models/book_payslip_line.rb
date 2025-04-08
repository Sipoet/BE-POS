class BookPayslipLine < ApplicationRecord

  validates :group, presence: true
  validates :payroll_type, presence: true
  validates :employee, presence: true
  validates :description, presence: true
  validates :amount, presence: true,numericality: {greater_than: 0}


  belongs_to :employee
  belongs_to :payroll_type
  belongs_to :payslip_line, optional: true

  enum :group,{
    earning: 0,
    deduction: 1
  }

  def status
    if payslip_line.present?
      :used
    else
      :not_used
    end
  end

end
