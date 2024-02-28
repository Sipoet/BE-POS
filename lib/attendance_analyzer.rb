class AttendanceAnalyzer

  def initialize(payroll:,employee:,start_date:,end_date:)
    @employee = employee
    @payroll = payroll
    @start_date = start_date
    @end_date = end_date
  end

  def analyze
    @work_schedules = @payroll.work_schedules
                             .group_by(&:day_of_week)
                             .each_with_object({}) do |(key,values),obj|
      obj[key] = values.sort_by(&:shift)
    end
    employee_leaves = EmployeeLeave.where(employee_id: @employee.id,
                                          date: @start_date..@end_date)
                                    .index_by(&:date)
    employee_attendances = find_attendances
    result = Result.new
    paid_time_off = @payroll.paid_time_off
    start_date = [@start_date, @employee.start_working_date].max
    (start_date..@end_date).each do |date|
      day_work_schedules = @work_schedules[date.cwday]
      employee_attendance = employee_attendances[date]
      if day_work_schedules.blank?
        if employee_attendance.present?
          result.work_days += 1
        end
        next
      end
      result.total_day += 1
      if employee_attendance.blank?
        employee_leave = employee_leaves[date]
        if employee_leave.blank?
          if paid_time_off > 0
            paid_time_off -= 1
          else
            result.unknown_absence += 1
          end
        elsif employee_leave.sick_leave?
          result.sick_leave += 1
        else
          result.known_absence += 1
        end
        next
      end
      work_schedule = find_work_schedule(day_work_schedules,employee_attendance)
      if work_schedule.long_shift_per_week.present? && work_schedule.long_shift_per_week > 0
        begin_work_time = schedule_of(date, day_work_schedules.first.begin_work)
        end_work_time = schedule_of(date, day_work_schedules.last.end_work)
        schedule_total_hours =((end_work_time - begin_work_time)/1.hour).round
        employee_total_hours =((employee_attendance.end_time - employee_attendance.start_time)/1.hour).round

        if employee_total_hours >= schedule_total_hours
          result.work_days +=2
          if employee_attendance.start_time <= begin_work_time && employee_attendance.end_time >= end_work_time
            result.overtime_hours << difference_hour(employee_attendance.end_time, end_work_time)
          elsif employee_attendance.start_time > begin_work_time
            result.late += 1
          end
          next
        elsif employee_total_hours.to_f < (schedule_total_hours/2.0)
          next
        end
      end
      begin_work_time = schedule_of(date, work_schedule.begin_work)
      end_work_time = schedule_of(date, work_schedule.end_work)
      if employee_attendance.start_time > begin_work_time
        result.late += 1

        if employee_attendance.end_time >= end_work_time
          result.work_days += 1
        end
      elsif employee_attendance.end_time>= end_work_time
        result.overtime_hours << difference_hour(employee_attendance.end_time, end_work_time)
        result.work_days += 1
      end

    end

    result.employee_worked_days = BigDecimal(total_employee_worked_days)
    result.paid_time_off = BigDecimal(@payroll.paid_time_off)
    result
  end

  private

  def find_attendances
    EmployeeAttendance.where(employee_id: @employee.id,
                             date: @start_date..@end_date)
                      .index_by(&:date)
  end

  def total_employee_worked_days
    @total_employee_worked_days ||= (@employee.start_working_date..@end_date).to_a.length
  end

  def total_day
    @total_day ||= (@start_date..@end_date).to_a.length
  end

  def total_unknown_leave(employee_attendances)
    [total_day, total_employee_worked_days].min - employee_attendances.count
  end

  def check_attendance(result,employee_attendance)
    late = 0
    overtime = []
    work_days = 0
    employee_attendances.each do |employee_attendance|
      work_schedule = find_work_schedule(employee_attendance)
      if work_schedule.blank?
        overtime << difference_hour(employee_attendance.start_time, employee_attendance.end_time)
        work_days += 1
        next
      end

      begin_work_time = schedule_of(employee_attendance.date, work_schedule.begin_work)
      end_work_time = schedule_of(employee_attendance.date, work_schedule.end_work)
      if employee_attendance.start_time > begin_work_time
        late += 1
        if employee_attendance.end_time >= end_work_time
          work_days += 1
        end
      elsif employee_attendance.end_time>= end_work_time
        overtime << difference_hour(employee_attendance.end_time, end_work_time)
        work_days += 1
      end
    end
    return [BigDecimal(work_days),BigDecimal(late), overtime]
  end

  def find_work_schedule(day_work_schedules,employee_attendance)
    flag = nil
    day_work_schedules.each do |work_schedule|
      begin_work_time = schedule_of(employee_attendance.date, work_schedule.begin_work)
      end_work_time = schedule_of(employee_attendance.date, work_schedule.end_work)
      if employee_attendance.start_time <= begin_work_time && employee_attendance.end_time >= end_work_time
        return work_schedule
      end

      if employee_attendance.start_time.between?(begin_work_time, end_work_time)
        flag = work_schedule
        next
      end
      if flag.present? && employee_attendance.end_time < end_work_time
        return flag
      else
        return work_schedule
      end
    end
    return flag
  end

  def find_changed_shift(date)
    employee_leave = EmployeeLeave.find_by(
      employee_id: @employee.id,
      change_date: date)
    employee_leave&.shift
  end

  def difference_hour(time_a, time_b)
    BigDecimal(((time_a.to_time - time_b.to_time)/1.hour).abs.ceil.to_s)
  end

  def schedule_of(date, time)
    Time.parse("#{date.iso8601} #{time}")
  end

  class Result
    attr_accessor :sick_leave,
                  :known_absence,
                  :work_days,
                  :total_day,
                  :paid_time_off,
                  :employee_worked_days,
                  :overtime_hours,
                  :unknown_absence,
                  :late

    def initialize
      @sick_leave = 0
      @known_absence = 0
      @work_days = 0
      @total_day = 0
      @paid_time_off = 0
      @employee_worked_days = 0
      @overtime_hours = []
      @unknown_absence = 0
      @late = 0
    end
  end
end
