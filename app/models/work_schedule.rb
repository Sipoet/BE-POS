class WorkSchedule < ApplicationRecord
  # enum :day_of_week, {
  #   sunday: 7,
  #   monday: 1,
  #   tuesday: 2,
  #   wednesday: 3,
  #   thursday: 4,
  #   friday: 5,
  #   saturday: 6
  # }

  validates :begin_work, presence: true
  validates :end_work, presence: true
  validates :day_of_week, presence: true, numericality: {greater_than:0, less_than: 8, integer: true}
  validate :end_work_must_valid
  validates :shift, presence: true, numericality: {greater_than: 0}


  belongs_to :payroll

  def end_work_must_valid
    today = Date.today
    if schedule_of(today, begin_work) > schedule_of(today, end_work)
      errors.add(:end_work,:greater_than, count: begin_work)
    end
  end

  def schedule_of(date,time)
    DateTime.parse("#{date.iso8601} #{time}")
  end
end
