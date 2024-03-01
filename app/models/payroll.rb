class Payroll < ApplicationRecord
  has_paper_trail

  TABLE_HEADER = [
    datatable_column(self,:name, :string),
    datatable_column(self,:paid_time_off, :integer),
    datatable_column(self,:description, :integer),
    datatable_column(self,:created_at, :datetime),
    datatable_column(self,:updated_at, :datetime),
  ].freeze

  validates :name, presence: true

  validates :payroll_lines, presence: true
  validates :work_schedules, presence: true

  has_many :payroll_lines, -> { order(row: :asc) }, dependent: :destroy
  has_many :employees, through: :employee_payrolls
  has_many :work_schedules, dependent: :destroy

  accepts_nested_attributes_for :payroll_lines, :work_schedules, allow_destroy: true

end
