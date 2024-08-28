class AttendanceAnalyzer

  def initialize(payroll:,employee:,start_date:,end_date:)
    @employee = employee
    @payroll = payroll
    @start_date = start_date
    @end_date = end_date
  end

  def analyze
    @work_schedules = find_employee_work_schedules
    @employee_leaves = EmployeeLeave.where(employee_id: @employee.id,
                                          date: @start_date..@end_date)
                                    .index_by(&:date)
    @changed_employee_leaves = EmployeeLeave.where(employee_id: @employee.id,
                                    change_date: @start_date..@end_date)
                              .index_by(&:change_date)
    @employee_day_offs = EmployeeDayOff.where(employee: @employee)
                                       .group_by(&:day_of_week)
    @holidays = Holiday.where(date: @start_date..@end_date)
                      .index_by(&:date)
    @employee_attendances = find_attendances
    @finder = WorkScheduleFinder.new(@employee.role_id)
    result = Result.new
    result.paid_time_off = BigDecimal(@payroll.paid_time_off)
    result.is_first_work = @employee.start_working_date.between?(@start_date,@end_date)
    result.is_last_work = @employee.end_working_date.present? && @employee.end_working_date.between?(@start_date,@end_date)
    (@start_date..@end_date).each {|date| analyze_date(date,result)}
    result.total_day = 26 if result.total_day < 26
    result
  end

  private

  def analyze_date(date,result)
    is_scheduled_work = scheduled_work?(date)
    if is_scheduled_work
      result.total_day += 1
    end
    return unless employee_still_working?(date)
    grouped_employee_attendances = @employee_attendances[date] || []

    work_hours = 0
    scheduled_work_hours = 0
    allow_overtime = false
    if grouped_employee_attendances.present?
      work_schedules = @finder.work_schedules_based_attendances(grouped_employee_attendances)
      shift = grouped_employee_attendances.first.try(:shift)
      if work_schedules.empty?
        work_schedules = @work_schedules.values.first.select{|work_schedule|work_schedule.shift == shift}
      end
      scheduled_work_hours = work_schedules.to_a.sum do |work_schedule|
        schedule_work_hours(work_schedule)
      end
      is_late = false
      grouped_employee_attendances.each.with_index do |employee_attendance,index|
        work_schedule = work_schedules[index]
        allow_overtime ||= employee_attendance.allow_overtime
        if work_schedule.present? && !work_schedule.is_flexible
          work_hours += work_hours_of(employee_attendance, work_schedule)
          scheduled_begin_at = schedule_of(date, work_schedule.begin_work)
          is_late ||= employee_attendance.is_late
          if is_late
            Rails.logger.debug "#{@employee.name} #{employee_attendance.start_time.iso8601} schedule: #{scheduled_begin_at.iso8601}"
          end
        else
          work_hours += difference_hour(employee_attendance.start_time,employee_attendance.end_time)
        end
      end
    end

    if work_hours > 0
      result.add_detail(
        date: date,
        work_hours: work_hours,
        shift: shift,
        scheduled_work_hours: scheduled_work_hours,
        is_late: is_late,
        allow_overtime:
      )
    elsif is_scheduled_work
      add_leave(result, date)
    end
  end

  def schedule_work_hours(work_schedule)
    date1 = Date.today
    date2 = work_schedule.begin_work > work_schedule.end_work ? Date.tomorrow : Date.today
    difference_hour(schedule_of(date1,work_schedule.begin_work),schedule_of(date2,work_schedule.end_work))
  end

  def find_employee_work_schedules
    @employee.role
            .role_work_schedules
            .where(begin_active_at: ..@end_date, end_active_at: @start_date..)
            .group_by(&:day_of_week)
  end

  def employee_still_working?(date)
    return false if @employee.start_working_date > date
    return !(@employee.end_working_date.present? && @employee.end_working_date < date)
  end

  def add_leave(result, date)
    employee_leave = @employee_leaves[date]
    if employee_leave.blank?
      Rails.logger.debug"===#{@employee.name} ALPHA tgl #{date}"
      result.add_detail(date: date, is_unknown_leave: true)
    elsif employee_leave.sick_leave?
      result.add_detail(date: date, is_sick: true)
    elsif !employee_leave.change_day?
      result.add_detail(date: date, is_known_leave: true)
    end
  end

  def scheduled_work?(date)
    return false unless employee_still_working?(date)
    return true if @changed_employee_leaves[date].present?
    return false if @holidays[date].present?
    day_offs = @employee_day_offs[date.cwday] || []
    day_offs.each do |employee_day_off|
      return false if employee_day_off.all_week?
      if employee_day_off.odd_week? == date.cweek.odd?
        return false
      end
      if employee_day_off.even_week? == date.cweek.even?
        return false
      end
      if date.prev_week.end_of_week.month < date.month && employee_day_off.first_week_of_month?
        return false
      end
      if date.next_week.month > date.month && employee_day_off.last_week_of_month?
        return false
      end
    end
    employee_leave = @employee_leaves[date]
    return false if employee_leave.present? && employee_leave.change_day?
    @work_schedules[date.cwday].present?
  end

  def find_attendances
    EmployeeAttendance.where(employee_id: @employee.id,
                             date: @start_date..@end_date)
                      .group_by(&:date)
  end

  def work_hours_of(employee_attendance, work_schedule)
    schedule_start_time = schedule_of(employee_attendance.date, work_schedule.begin_work)
    start_time = [schedule_start_time, employee_attendance.start_time].max
    end_time = if employee_attendance.allow_overtime
      employee_attendance.end_time
    else
      [employee_attendance.end_time, schedule_of(employee_attendance.date, work_schedule.end_work)].min
    end
    difference_hour(start_time, end_time)
  end

  def difference_hour(time_a, time_b)
    BigDecimal(((time_a.to_time - time_b.to_time)/1.hour).round(1).abs.to_s)
  end

  def schedule_of(date, time)
    Time.parse("#{date.iso8601} #{time}")
  end

  class Result
    attr_accessor :total_day,
                  :paid_time_off,
                  :is_first_work,
                  :is_last_work,
                  :overtime_hours,
                  :total_full_work_days

    attr_reader :details

    def initialize
      @total_day = 0
      @paid_time_off = 0
      @overtime_hours = 0
      @total_full_work_days = 0
      @details = []
    end

    def add_detail(date:, is_late: false, allow_overtime: false,work_hours: 0,scheduled_work_hours: 0, is_sick: false, is_known_leave: false, is_unknown_leave: false, shift: 1)
      @details << ResultDetail.new(
        date: date,
        is_late: is_late,
        work_hours: work_hours,
        shift: shift,
        scheduled_work_hours: scheduled_work_hours,
        is_sick: is_sick,
        is_known_leave: is_known_leave,
        is_unknown_leave: is_unknown_leave,
        allow_overtime: allow_overtime
      )
    end

    def sick_leave
      details.count(&:is_sick)
    end

    def late
      details.count(&:is_late)
    end

    def known_absence
      details.count(&:is_known_leave)
    end

    def work_days
      details.count(&:work_in?)
    end

    def unknown_absence
      details.count(&:is_unknown_leave)
    end

    def work_hours
      details.map(&:work_hours)
    end

  end

  class ResultDetail
    attr_accessor :date, :is_worked, :is_late, :work_hours,
                  :is_sick, :is_known_leave, :is_unknown_leave,
                  :scheduled_work_hours, :allow_overtime, :shift
    def initialize(date:, is_late:, work_hours:,allow_overtime:, is_sick:, is_known_leave: , is_unknown_leave:, scheduled_work_hours:, shift:)
      @date = date
      @is_late = is_late
      @work_hours = work_hours
      @is_sick = is_sick
      @is_known_leave = is_known_leave
      @is_unknown_leave = is_unknown_leave
      @scheduled_work_hours = scheduled_work_hours
      @allow_overtime = allow_overtime
      @shift = shift
    end

    def work_in?
      work_hours > 0
    end
  end
end
