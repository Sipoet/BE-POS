class Payroll < ApplicationRecord
  has_paper_trail ignore: [:created_at, :updated_at]

  TABLE_HEADER = [
    datatable_column(self,:name, :string),
    datatable_column(self,:paid_time_off, :integer),
    datatable_column(self,:description, :integer),
    datatable_column(self,:created_at, :datetime),
    datatable_column(self,:updated_at, :datetime),
  ].freeze

  validates :name, presence: true

  validates :payroll_lines, presence: true

  has_many :payroll_lines, -> { order(row: :asc) }, dependent: :destroy
  has_many :employees, through: :employee_payrolls

  accepts_nested_attributes_for :payroll_lines, allow_destroy: true

end
