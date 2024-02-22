class EmployeeLeave < ApplicationRecord
  enum :leave_type, {
    sick_leave: 0,
    annual_leave: 1,
    unpaid_leave: 2,
    maternal_leave: 3,
    public_holiday_leave: 4
  }
  validates :leave_type, presence: true
  validates :date, presence: true
  belongs_to :employee
end
