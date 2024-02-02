class EmployeeAttendance::MassUploadService < ApplicationService

  def execute_service
    sheet = read_excel!(params[:file])
    range = extract_period(sheet)
    employee_attendances = extract_to_employee_attendance(sheet, range)
    puts employee_attendances
    remove_old_attendances(range)
    EmployeeAttendance.insert_all!(employee_attendances)
  end

  private

  def remove_old_attendances(range)
    EmployeeAttendance.where("start_time <= ? AND end_time >= ?", range.last.end_of_day, range.first.beginning_of_day)
                      .delete_all
  end

  def read_excel!(file)
    workbook = Xsv.open(file.path)
    workbook['Log']
  end

  def extract_to_employee_attendance(sheet, range)
    first_day = range.first.try(:day)
    selected_employee = nil
    employee_attendances = []
    sheet.to_a[4..-1].each do |rows|
      if rows[0] == 'No :'
        selected_employee = find_employee(rows)
        next
      end
      next if rows[0].to_s == first_day.to_s
      next if selected_employee.nil?
      employee_attendances += extract_time_attendance(rows,selected_employee,range)
      selected_employee = nil
    end
    employee_attendances
  end

  def extract_time_attendance(rows,selected_employee,range)
    time_attendance = []
    range.each.with_index do |date, index|
      row = rows[index]
      next if row.nil?
      attendances = row.split("\r\n")
      start_time = DateTime.parse("#{date.iso8601} #{attendances[0].strip}")
      end_time = DateTime.parse("#{date.iso8601} #{attendances[-1].strip}")
      time_attendance << {
        employee_id: selected_employee.id,
        start_time: start_time,
        end_time: end_time
      }
    end
    time_attendance
  end

  def find_employee(rows)
    employee_code = rows[2]
    Employee.find_by(code: employee_code, status: :active)
  end

  def extract_period(sheet)
    period_text = sheet[2][2]
    @start_date = Date.strptime(period_text.split('~').first.strip,'%Y/%m/%d')
    @end_date = @start_date + (sheet[3].compact.length - 1).days
    @start_date..@end_date
  end
end
