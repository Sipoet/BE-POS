class AttendanceAnalyzer

  def initialize(payroll:,employee:,start_date:,end_date:)
    @employee = employee
    @payroll = payroll
    @start_date = start_date
    @end_date = end_date
  end

  def analyze
    employee_attendances = find_attendances
    result = Result.new
    # total day employee work since beginning
    result.employee_work_days = BigDecimal(total_employee_work_days)
    result.total_day = BigDecimal(total_day)
    result.sick_leave = BigDecimal(total_sick_leave)
    result.known_absence = BigDecimal(total_known_absence_leave)
    result.work_days = BigDecimal(employee_attendances.count)
    result.unknown_absence = BigDecimal(total_unknown_leave(employee_attendances))
    result.late, result.overtime_hours = total_late_and_overtime(employee_attendances)
    result.paid_time_off = BigDecimal(@payroll.paid_time_off)
    result
  end

  private

  def find_attendances
    EmployeeAttendance.where(employee_id: @employee.id,
                             date: @start_date..@end_date)
  end

  def total_employee_work_days
    @total_employee_work_days ||= (@employee.start_working_date..@end_date).to_a.length
  end

  def total_day
    @total_day ||= (@start_date..@end_date).to_a.length
  end

  def total_unknown_leave(employee_attendances)
    [total_day, total_employee_work_days].min - employee_attendances.count
  end

  def total_late_and_overtime(employee_attendances)
    work_schedules = @payroll.work_schedules
                             .to_a
                             .sort_by{|work_schedule| schedule_of(Date.today, work_schedule.begin_work) }
    late = 0
    overtime = []
    total_shift = work_schedules.length
    employee_attendances.each do |employee_attendance|
      flag = false
      work_schedules.each.with_index(1) do |work_schedule, index|
        begin_work_time = schedule_of(employee_attendance.date, work_schedule.begin_work)
        end_work_time = schedule_of(employee_attendance.date, work_schedule.end_work)
        if employee_attendance.start_time.between?(begin_work_time, end_work_time)
          flag = true
          next
        end
        if flag && employee.end_time < end_work_time
          late +=1
          flag = false
        else
          flag = false
        end
        if employee_attendance.end_time> end_work_time && employee_attendance.start_time <= begin_work_time
          overtime << difference_hour(employee_attendance.end_time, end_work_time)
          break
        end

      end

    end

    return BigDecimal(late), overtime
  end

  def difference_hour(time_a, time_b)
    BigDecimal((time_a.to_time - time_b.to_time)/1.hour).abs.ceil
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
                  :employee_work_days,
                  :overtime_hours,
                  :unknown_absence,
                  :late
  end
end
