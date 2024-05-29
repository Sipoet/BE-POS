class AttendanceAnalyzer

  def initialize(payroll:,employee:,start_date:,end_date:)
    @employee = employee
    @payroll = payroll
    @start_date = start_date
    @end_date = end_date
  end

  def analyze
    @work_schedules = @employee.work_schedules
                             .group_by(&:day_of_week)
                             .each_with_object({}) do |(key,values),obj|
      obj[key] = values.sort_by{|value| -1 * value.active_week_for_database}
    end
    employee_leaves = EmployeeLeave.where(employee_id: @employee.id,
                                          date: @start_date..@end_date)
                                    .index_by(&:date)
    holidays = Holiday.where(date: @start_date..@end_date)
                      .index_by(&:date)
    employee_attendances = find_attendances
    result = Result.new
    result.paid_time_off = BigDecimal(@payroll.paid_time_off)
    result.is_first_work = @employee.start_working_date.between?(@start_date,@end_date)
    result.is_last_work = @employee.end_working_date.present? && @employee.end_working_date.between?(@start_date,@end_date)
    paid_time_off = @payroll.paid_time_off
    end_period = @start_date.next_month
    (@start_date..@end_date).each do |date|
      grouped_employee_attendances = employee_attendances[date]
      work_schedule = find_work_schedule(date)
      if work_schedule.blank?
        work_schedule = find_work_schedule_from_leave(date)
      elsif holidays[date].nil?
        result.total_day += 1
      end
      if work_schedule.blank?
        if grouped_employee_attendances.present?
          work_hours = sum_work_hours(grouped_employee_attendances)
          result.add_detail(date: date, work_hours: work_hours)
        end
        next
      end
      next if @employee.start_working_date > date
      next if @employee.end_working_date.present? && @employee.end_working_date < date
      employee_leave = employee_leaves[date]
      if grouped_employee_attendances.blank?
        next if holidays[date].present?
        if employee_leave.blank?
          Rails.logger.info "=== date: #{date}"
          result.add_detail(date: date, is_unknown_leave: true)
        elsif employee_leave.sick_leave?
          result.add_detail(date: date, is_sick: true)
        elsif !employee_leave.change_day?
          result.add_detail(date: date, is_known_leave: true)
        end
        next
      end
      begin_work_time = schedule_of(date, work_schedule.begin_work)
      work_hours = sum_work_hours(grouped_employee_attendances, begin_work_time)
      employee_attendance = grouped_employee_attendances.first
      result.add_detail(date: date, work_hours: work_hours, is_late: employee_attendance.start_time > begin_work_time)
    end
    result.total_day = 27 if result.total_day < 27
    result
  end

  private

  def find_attendances
    EmployeeAttendance.where(employee_id: @employee.id,
                             date: @start_date..@end_date)
                      .group_by(&:date)
  end

  def sum_work_hours(employee_attendances, schedule_start_time = nil)
    employee_attendances.sum do |employee_attendance|
      start_time = schedule_start_time.present? && schedule_start_time > employee_attendance.start_time ? schedule_start_time : employee_attendance.start_time
      difference_hour(start_time, employee_attendance.end_time)
    end
  end

  def find_work_schedule(date)
    day_work_schedules = @work_schedules[date.cwday] || []
    date_status = [
      date.cweek.odd?,
      date.cweek.even?,
      date.prev_week.end_of_week.month < date.month,
      date.next_week.month > date.month
    ]
    day_work_schedules.each do |work_schedule|
      if work_schedule.all_week? || (date_status[0] && work_schedule.odd_week?) ||
        (date_status[1] && work_schedule.even_week?) ||
        (date_status[2] && work_schedule.first_week_of_month?) ||
        (date_status[3] && work_schedule.last_week_of_month?)
        return work_schedule
      end
    end
    nil
  end

  def find_work_schedule_from_leave(date)
    employee_leave = EmployeeLeave.find_by(employee_id: @employee.id, change_date: date)
    return nil if employee_leave.blank?
    @work_schedules.values
                   .flatten
                   .find{|work_schedule|work_schedule.shift == employee_leave.change_shift}
  end

  def find_changed_shift(date)
    employee_leave = EmployeeLeave.find_by(
      employee_id: @employee.id,
      change_date: date)
    employee_leave&.shift
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

    def add_detail(date:, is_late: false, work_hours: 0, is_sick: false, is_known_leave: false, is_unknown_leave: false)
      @details << ResultDetail.new(
        date: date,
        is_late: is_late,
        work_hours: work_hours,
        is_sick: is_sick,
        is_known_leave: is_known_leave,
        is_unknown_leave: is_unknown_leave
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
                  :is_sick, :is_known_leave, :is_unknown_leave
    def initialize(date:, is_late: false, work_hours: 0, is_sick: false, is_known_leave: false, is_unknown_leave: false)
      @date = date
      @is_late = is_late
      @work_hours = work_hours
      @is_sick = is_sick
      @is_known_leave = is_known_leave
      @is_unknown_leave = is_unknown_leave
    end

    def work_in?
      work_hours > 0
    end
  end
end
