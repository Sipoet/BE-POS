class EmployeeLeave < ApplicationRecord
  has_paper_trail
  TABLE_HEADER = [
    datatable_column(self,:employee_id, :link,path:'employees',attribute_key: 'employee.name'),
    datatable_column(self,:date, :date),
    datatable_column(self,:leave_type, :enum),
    datatable_column(self,:change_date, :date),
    datatable_column(self,:change_shift, :integer),
    datatable_column(self,:description, :string),
    datatable_column(self,:created_at, :datetime),
    datatable_column(self,:updated_at, :datetime),
  ]
  enum :leave_type, {
    sick_leave: 0,
    annual_leave: 1,
    maternal_leave: 2,
    change_day: 3,
    unpaid_leave: 4,
    public_holiday_leave: 5
  }
  validates :leave_type, presence: true
  validates :date, presence: true
  validate :change_day_valid

  belongs_to :employee

  private
  def change_day_valid
    return if !change_day?
    if change_date.blank?
      errors.add(:change_date, :blank)
    end
    if change_shift.blank?
      errors.add(:change_shift, :blank)
    end
  end
end
