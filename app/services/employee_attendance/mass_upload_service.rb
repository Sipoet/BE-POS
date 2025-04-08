class EmployeeAttendance::MassUploadService < ApplicationService

  def execute_service
    sheet = read_excel!(params[:file])
    range = extract_period(sheet)
    employee_attendances = extract_to_employee_attendance(sheet, range)
    remove_old_attendances(range)
    ApplicationRecord.transaction do
      result = EmployeeAttendance.insert_all!(employee_attendances, returning: [:id])
      ids = result.to_a.map{|row|row['id']}
      override_overtime_and_late(range, ids)
      employee_attendances = EmployeeAttendance.where(id: ids).includes(:employee)
    end
    render_json(EmployeeAttendanceSerializer.new(employee_attendances,{include:['employee'],field:{employee: [:id,:name]}}),{status: :created})

  end

  private

  def override_overtime_and_late(range, employee_attendance_ids)
    book_employee_attendances = BookEmployeeAttendance.where(start_date: ..(range.last), end_date: (range.first)..)
    book_employee_attendances.each do |book|
      query = EmployeeAttendance.where(id: employee_attendance_ids, date: (book.start_date)..(book.end_date))
      attributes = {}
      if book.employee_id.present?
        query = query.where(employee_id: book.employee_id)
      end
      if !book.allow_overtime.nil?
        attributes[:allow_overtime] = book.allow_overtime
      end
      if !book.is_late.nil?
        attributes[:is_late] = book.is_late
      end
      query.update_all(attributes)
    end
  end

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
    time_attendances = []
    finder = WorkScheduleFinder.new(selected_employee.role_id)
    range.each.with_index do |date, index|
      row = rows[index]
      next if row.nil?
      attendances = row.split("\r\n")
                       .map{|hour| parse_time(date,hour)}

      if rows[index + 1].present?
        next_attendances = rows[index + 1].split("\r\n")
        next_attendances.each do |hour|
          attendances << parse_time(date.tomorrow, hour)
        end
      end
      attendances.select!{|datetime| datetime.between?(parse_time(date, open_hour_offset), parse_time(date.tomorrow, open_hour_offset))}
      attendances.uniq!
      start_time = nil
      end_time = nil
      day_attendances = []
      attendances.each.with_index do |datetime, index|
        if start_time.nil?
          start_time = datetime
          next
        end
        end_time = datetime
        next if difference_minute(start_time,end_time) < min_read_attendance
        next if (attendances[index + 1].present? && difference_minute(end_time, attendances[index + 1]) < min_read_attendance)
        day_attendances << {
          employee_id: selected_employee.id,
          start_time: start_time,
          end_time: end_time,
          date: date,
        }
        start_time = nil
        end_time = nil
      end
      if start_time.present? && end_time.blank?
        time_str = Setting.get("scheduled_store_end_time") || '22:00'
        scheduled_store_end_time = Time.zone.parse("#{date.iso8601} #{time_str}")
        end_time = start_time
        if start_time >= scheduled_store_end_time
          start_time -= 4.hour
        else
          end_time += 4.hour
        end
        day_attendances << {
          employee_id: selected_employee.id,
          start_time: start_time,
          end_time: end_time,
          date: date,
        }
      end
      arr_range_date = day_attendances.map{|line| line[:start_time]..(line[:end_time])}
      shift = finder.shift_based_arr_range_date(arr_range_date)
      work_schedules = finder.find_estimate_work_schedules(arr_range_date)
      day_attendances.each do|attendance|
        attendance[:shift] = shift
        work_schedule = work_schedules[0]
        if work_schedule.present?
          attendance[:is_late] = late?(parse_time(attendance[:date], work_schedule.begin_work), attendance[:start_time])
        end
      end

      time_attendances += day_attendances
    end
    time_attendances
  end

  def late?(schedule_start_time, actual_start_at)
    schedule_start_time + late_offset_in_minute < actual_start_at
  end

  def late_offset_in_minute
    @late_offset_in_minute ||= (Setting.get('offset_late_attendance_in_minute')|| 0).to_i.minutes
  end

  def open_hour_offset
    @store_open_hour ||= (Setting.get('day_separator_at') || '07:00')
  end

  # minimum minute that will be read as block of attendance in & out, less then setting will assumed is same type write absent before
  def min_read_attendance
    @min_read_attendance ||= ((Setting.get('attendance_minute_offset') || '60').to_d)
  end

  def find_employee(rows)
    employee_code = rows[10].try(:downcase)
    return nil if employee_code.nil?
    Employee.find_by(code: employee_code, status: :active) || Employee.find_by(code: employee_code)
  end

  def parse_time(date, hour)
    Time.zone.parse("#{date.iso8601} #{hour}")
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
