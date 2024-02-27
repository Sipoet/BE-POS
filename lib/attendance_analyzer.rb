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
    employee_attendances = find_attendances
    result = Result.new
    result.work_days, result.late, result.overtime_hours = attendance_summary(employee_attendances)
    # total day employee work since beginning
    result.employee_worked_days = BigDecimal(total_employee_worked_days)
    result.total_day = BigDecimal(total_day)
    result.sick_leave = BigDecimal(total_sick_leave)
    result.known_absence = BigDecimal(total_known_absence_leave)
    result.unknown_absence = [result.total_day, result.employee_worked_days].min - [result.work_days, result.known_absence, result.sick_leave].sum
    result.paid_time_off = BigDecimal(@payroll.paid_time_off)
    result
  end

  private

  def find_attendances
    EmployeeAttendance.where(employee_id: @employee.id,
                             date: @start_date..@end_date)
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

  def attendance_summary(employee_attendances)
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

  def find_work_schedule(employee_attendance)
    day_work_schedules = @work_schedules[employee_attendance.date.cwday]
    if day_work_schedules.nil?
      shift = find_changed_shift(employee_attendance.date)
      return nil if shift.nil?
      return @payroll.work_schedules.find_by(shift: shift)
    end
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
    DateTime.parse("#{date.iso8601} #{time}")
  end

  def total_sick_leave
    EmployeeLeave.where(employee_id: @employee.id,
                        date: @start_date..@end_date,
                        leave_type: :sick_leave)
                 .count
  end

  def total_known_absence_leave
    EmployeeLeave.where(employee_id: @employee.id,
                        date: @start_date..@end_date,
                        leave_type: [:annual_leave, :unpaid_leave,:maternal_leave])
                 .count
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
  end
end
