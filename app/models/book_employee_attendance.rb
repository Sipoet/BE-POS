class BookEmployeeAttendance < ApplicationRecord
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_should_valid

  belongs_to :employee, optional: true

  private

  def end_date_should_valid
    return if start_date.nil? || end_date.nil?

    return unless end_date < start_date

    errors.add(:end_date, :greater_than, count: start_date.strftime('%d/%m/%y'))
  end
end
