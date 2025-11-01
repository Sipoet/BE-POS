class EmployeeAttendance < ApplicationRecord
  has_paper_trail

  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_valid

  belongs_to :employee

  def start_work
    start_time.strftime('%H:%M')
  end

  def end_work
    end_time.strftime('%H:%M')
  end

  private

  def end_time_valid
    return if start_time.blank? || end_time.blank?

    return unless start_time > end_time

    errors.add(:end_time, :greater_than, count: start_time)
  end
end
