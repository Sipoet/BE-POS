class Payroll::Formula::HourlyDailyCalculator < Payroll::Formula::ApplicationCalculator
  # variable1 = amount of pay
  # variable2 = how many work hour include rest hour per day.
  #             if empty or zero, how many hours based on scheduled
  # variable3 = include sick day? 1 is true, anything else is false
  # variable4 = how many day get amount of pay. if empty use total day scheduled work
  def calculate
    total_work_day = 0
    min_work_calc = ->(_detail) { payroll_line.variable2.to_d }
    if payroll_line.variable2 == 0 || payroll_line.variable2.blank?
      min_work_calc = lambda { |detail|
        detail.is_late ? detail.scheduled_work_hours.to_d + 1 : detail.scheduled_work_hours.to_d
      }
    end
    attendance_summary.details.each do |detail|
      next if detail.work_hours == 0

      min_work = min_work_calc.call(detail)
      work_hours = [detail.work_hours, min_work].min.to_d
      total_work_day += (work_hours / min_work)
      Rails.logger.debug "#{@employee.name} #{detail.date} kerja #{work_hours} jam. min work #{min_work} total work days #{total_work_day}"
    end
    attendance_summary.total_full_work_days = total_work_day.round(1)
    separator = (payroll_line.variable4 || attendance_summary.total_day).to_d
    fraction = if include_sick_day?(payroll_line)
                 attendance_summary.total_full_work_days.to_d + attendance_summary.sick_leave
               else
                 attendance_summary.total_full_work_days.to_d
               end
    (fraction * payroll_line.variable1.to_d / separator).round(payslip_round)
  end

  def self.main_amount(payroll_line)
    payroll_line.variable1
  end

  def self.full_amount(payroll_line)
    payroll_line.variable1
  end

  private

  def include_sick_day?(payroll_line)
    payroll_line.variable3 == 1
  end

  def payslip_round
    (Setting.get('payslip_round') || -2).to_i
  end
end
