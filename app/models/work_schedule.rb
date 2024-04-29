class WorkSchedule < ApplicationRecord
  enum :active_week, {
    all_week: 0,
    odd_week: 1,
    even_week: 2,
    first_week_of_month: 3,
    last_week_of_month: 4,
  }

  validates :begin_work, presence: true
  validates :end_work, presence: true
  validates :day_of_week, presence: true, numericality: {greater_than:0, less_than: 8, integer: true}
  validate :end_work_must_valid
  validates :shift, presence: true, numericality: {greater_than: 0}

  belongs_to :employee

  def end_work_must_valid
    today = Date.today
    if schedule_of(today, begin_work) > schedule_of(today, end_work)
      errors.add(:end_work,:greater_than, count: begin_work)
    end
  end

  private
  def schedule_of(date,time)
    DateTime.parse("#{date.iso8601} #{time}")
  end
end
