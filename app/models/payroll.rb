class Payroll < ApplicationRecord

  def begin_schedule_of(date)
    DateTime.parse("#{date.iso8601} #{begin_schedule}")
  end

  def end_schedule_of(date)
    DateTime.parse("#{date.iso8601} #{end_schedule}")
  end
end
