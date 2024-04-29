class EmployeeAttendance::MassUploadService < ApplicationService

  def execute_service
    sheet = read_excel!(params[:file])
    range = extract_period(sheet)
    employee_attendances = extract_to_employee_attendance(sheet, range)
    remove_old_attendances(range)
    ApplicationRecord.transaction do
      result = EmployeeAttendance.insert_all!(employee_attendances, returning: [:id])
      ids = result.to_a.map{|row|row['id']}
      employee_attendances = EmployeeAttendance.where(id: ids).includes(:employee)
      render_json(EmployeeAttendanceSerializer.new(employee_attendances,{include:['employee'],field:{employee: [:id,:name]}}),{status: :created})
    end
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
                       .map{|hour| parse_time(date,hour)}

      if rows[index + 1].present?
        last_hour = rows[index + 1].split("\r\n")[0]
        attendances << parse_time(date.tomorrow, last_hour) if parse_time(date.tomorrow, last_hour) < parse_time(date.tomorrow, '07:00')
      end
      attendances.shift if attendances.first < parse_time(date, open_hour_offset)
      attendances.uniq!
      start_time = nil
      end_time = nil
      attendances.each.with_index do |datetime, index|
        if start_time.nil?
          start_time = datetime
          next
        end
        end_time = datetime
        next if difference_minute(start_time,end_time) < time_offset
        next if (attendances[index + 1].present? && difference_minute(end_time, attendances[index + 1]) < time_offset)
        time_attendance << {
          employee_id: selected_employee.id,
          start_time: start_time,
          end_time: end_time,
          date: date,
        }
        start_time = nil
        end_time = nil
      end
      if start_time.present? && end_time.blank?
        time_attendance << {
          employee_id: selected_employee.id,
          start_time: start_time,
          end_time: start_time + 4.hour,
          date: date,
        }
      end
    end
    time_attendance
  end

  def open_hour_offset
    @store_open_hour ||= (Setting.get('day_separator_at') || '07:00')
  end

  def time_offset
    @time_offset ||= ((Setting.get('attendance_minute_offset') || '60').to_d)
  end

  def find_employee(rows)
    employee_code = rows[10].try(:downcase)
    return nil if employee_code.nil?
    Employee.find_by(code: employee_code, status: :active) || Employee.find_by(code: employee_code)
  end

  def parse_time(date, hour)
    Time.parse("#{date.iso8601} #{hour}")
  end

  def difference_minute(time_a,time_b)
    BigDecimal(((time_a.to_time - time_b.to_time)/1.minute).round.abs.to_s)
  end

  def extract_period(sheet)
    period_text = sheet[2][2]
    @start_date = Date.strptime(period_text.split('~').first.strip,'%Y/%m/%d')
    @end_date = @start_date + (sheet[3].compact.length - 1).days
    @start_date..@end_date
  end
end
