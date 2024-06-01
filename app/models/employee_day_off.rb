class EmployeeDayOff < ApplicationRecord
  has_paper_trail ignore: [:id, :created_at, :updated_at]
  enum :active_week, {
    all_week: 0,
    odd_week: 1,
    even_week: 2,
    first_week_of_month: 3,
    last_week_of_month: 4,
  }

  validates :active_week, presence: true
  belongs_to :employee
end
