class Payslip < ApplicationRecord
  has_paper_trail ignore: [:id, :created_at, :updated_at]

  enum :status, {
    draft: 0,
    confirmed: 1,
    paid: 2,
    cancelled: 3
  }
  belongs_to :payroll
  belongs_to :employee
  has_many :payslip_lines, dependent: :destroy, inverse_of: :payslip
  accepts_nested_attributes_for :payslip_lines, allow_destroy: true
  [:work_days, :sick_leave, :known_absence, :unknown_absence].each do |key|
    validates key, presence: true, numericality:{greater_than_or_equal_to: 0}
  end
end
