class Payroll < ApplicationRecord
  has_paper_trail ignore: %i[id created_at updated_at]

  validates :name, presence: true

  validates :payroll_lines, presence: true

  has_many :payroll_lines, -> { order(row: :asc) }, dependent: :destroy, inverse_of: :payroll

  accepts_nested_attributes_for :payroll_lines, allow_destroy: true
end
