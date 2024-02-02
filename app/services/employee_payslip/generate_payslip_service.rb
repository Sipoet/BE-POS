class EmployeePayslip::GeneratePayslipService < ApplicationService

  def execute_service
    extract_params
    employee_attendances = get_attendance
    detail = get_detail(employee_attendances)
    summary = calculate_payslip(detail)
    create_payslip(summary,detail)
    detail
  end

  private

  def create_payslip(summary,detail)
  end

  def calculate_payslip(detail)
  end

  def get_detail(employee_attendances)
    date_range = (@start_date..@end_date).to_a
    detail = {
      sick_leave: 0,
      absence: 0,
      total_day: date_range.length,
      pto: 0 ,
      holiday: 0,
      overtime_hour: 0,
      alpha: 0,
      late: 0
    }
    employee_attendances.each do |employee_attendance|
      detail[:absence] += 1
      date = employee_attendance.start_time.to_date
      date_range.reject!{|date1| date1 == date}
      limit_start = @employee.begin_schedule_of(date)
      limit_end = @employee.end_schedule_of(date)
      start_time = [employee_attendance.start_time, limit_start].max
      detail[:late] +=1 if employee_attendance.start_time > limit_start + 5.minute
      if employee_attendance.end_time > limit_end + 1.hour
        debugger
        detail[:overtime_hour] += ((employee_attendance.end_time - limit_end)/1.hour).floor
      end
    end

    detail[:alpha] = date_range.length
    puts detail
    detail
  end

  def get_attendance
    EmployeeAttendance.where('start_time <= ? AND end_time >= ? AND employee_id = ?',
                              @end_date.end_of_day,
                              @start_date.beginning_of_day,
                              @employee.id)
                      .order(start_time: :asc)

  end

  def extract_params
    @employee = Employee.find(params[:employee_id].to_i)
    @start_date = Date.parse(params[:start_date])
    @end_date = Date.parse(params[:end_date])
  end

end
