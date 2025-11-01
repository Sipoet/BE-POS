class EmployeeLeave < ApplicationRecord
  has_paper_trail ignore: %i[id created_at updated_at]

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
    if change_day?
      errors.add(:change_date, :blank) if change_date.blank?
      errors.add(:change_shift, :blank) if change_shift.blank?
    else
      errors.add(:change_date, :present) if change_date.present?
      errors.add(:change_shift, :present) if change_shift.present?
    end
  end
end
