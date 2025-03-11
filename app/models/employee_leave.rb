class EmployeeLeave < ApplicationRecord
  has_paper_trail ignore: [:id, :created_at, :updated_at]

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
      if change_date.blank?
        errors.add(:change_date, :blank)
      end
      if change_shift.blank?
        errors.add(:change_shift, :blank)
      end
    else
      if change_date.present?
        errors.add(:change_date, :present)
      end
      if change_shift.present?
        errors.add(:change_shift, :present)
      end
    end

  end
end
