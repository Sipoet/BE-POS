class EmployeeLeave < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:employee_name, :string),
    datatable_column(self,:date, :string),
    datatable_column(self,:leave_type, :string)
  ]
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
