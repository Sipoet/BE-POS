class EmployeeAttendance::MassUploadService < ApplicationService
  def execute_service
    sheet = read_excel!(params[:file])
    range = extract_period(sheet)
    employee_attendances = extract_to_employee_attendance(sheet, range)
    remove_old_attendances(range)
    ApplicationRecord.transaction do
      result = EmployeeAttendance.insert_all!(employee_attendances, returning: [:id])
      ids = result.to_a.map { |row| row['id'] }
      override_overtime_and_late(range, ids)
      employee_attendances = EmployeeAttendance.where(id: ids).includes(:employee)
    end
    render_json(
      EmployeeAttendanceSerializer.new(employee_attendances,
                                       { include: ['employee'],
                                         field: { employee: %i[id name] } }), { status: :created }
    )
  end

  private

  def override_overtime_and_late(range, employee_attendance_ids)
    book_employee_attendances = BookEmployeeAttendance.where(start_date: ..(range.last), end_date: (range.first)..)
    book_employee_attendances.each do |book|
      query = EmployeeAttendance.where(id: employee_attendance_ids, date: (book.start_date)..(book.end_date))
      attributes = {}
      query = query.where(employee_id: book.employee_id) if book.employee_id.present?
      attributes[:allow_overtime] = book.allow_overtime unless book.allow_overtime.nil?
      attributes[:is_late] = book.is_late unless book.is_late.nil?
      query.update_all(attributes)
    end
  end

  def remove_old_attendances(range)
    EmployeeAttendance.where('start_time <= ? AND end_time >= ?', range.last.end_of_day, range.first.beginning_of_day)
                      .delete_all
  end

  def read_excel!(file)
    workbook = Xsv.open(file.path)
    workbook.first
  end

  def extract_to_employee_attendance(sheet, range)
    first_day = range.first.try(:day)
    selected_employee = nil
    employee_attendances = []
    row_containers = []
    sheet.to_a[4..-1].each do |rows|
      if rows[4].to_s.include?('User ID')
        if selected_employee.present?
          employee_attendances += extract_time_attendance(row_containers, selected_employee, range)
          selected_employee = nil
          row_containers = []
        end
        selected_employee = find_employee(rows)
        next
      end
      next if rows[1].to_s == first_day.to_s
      next if selected_employee.nil?

      row_containers << rows
    end
    employee_attendances
  end

  def extract_time_attendance(row_containers, selected_employee, range)
    first_row = row_containers.first
    time_attendances = []
    finder = WorkScheduleFinder.new(selected_employee.role_id)
    range.each.with_index(1) do |date, index|
      row = first_row[index]
      next if row.blank?

      attendances = row_containers.map do |rows|
        rows[index]&.split("\r\n")
                   &.map { |hour| parse_time(date, hour) }
      end.flatten.compact

      if first_row[index + 1].present?
        next_attendances = first_row[index + 1].split("\r\n")
        next_attendances.each do |hour|
          attendances << parse_time(date.tomorrow, hour)
        end
      end
      attendances.select! do |datetime|
        datetime.between?(parse_time(date, open_hour_offset), parse_time(date.tomorrow, open_hour_offset))
      end
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
        if difference_minute(start_time, end_time) < min_read_attendance
          end_time = nil
          next
        end
        next if attendances[index + 1].present? && difference_minute(end_time,
                                                                     attendances[index + 1]) < min_read_attendance

        day_attendances << {
          employee_id: selected_employee.id,
          start_time: start_time,
          end_time: end_time,
          date: date
        }
        start_time = nil
        end_time = nil
      end
      if start_time.present? && end_time.blank?
        time_str = Setting.get('scheduled_store_end_time') || '22:00'
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
          date: date
        }
      end
      arr_range_date = day_attendances.map { |line| line[:start_time]..(line[:end_time]) }
      shift = finder.shift_based_arr_range_date(arr_range_date)
      work_schedules = finder.find_estimate_work_schedules(arr_range_date)
      day_attendances.each do |attendance|
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
    @late_offset_in_minute ||= (Setting.get('offset_late_attendance_in_minute') || 0).to_i.minutes
  end

  def open_hour_offset
    @store_open_hour ||= Setting.get('day_separator_at') || '07:00'
  end

  # minimum minute that will be read as block of attendance in & out, less then setting will assumed is same type write absent before
  def min_read_attendance
    @min_read_attendance ||= (Setting.get('in_out_attendance_minute_offset') || '60').to_d
  end

  def find_employee(rows)
    employee_code = rows[11].try(:downcase)
    return nil if employee_code.nil?

    Employee.find_by(code: employee_code, status: :active) || Employee.find_by(code: employee_code)
  end

  def parse_time(date, hour)
    Time.zone.parse("#{date.iso8601} #{hour}")
  end

  def difference_minute(time_a, time_b)
    BigDecimal(((time_a.to_time - time_b.to_time) / 1.minute).round.abs.to_s)
  end

  def extract_period(sheet)
    sheet.to_a.each.with_index(0) do |row, index|
      Rails.logger.debug "index #{index} : #{row.map.with_index { |text, index2| "#{index2}: #{text}" }.join('|')}"
    end
    period_text = sheet[2][25]
    period_text = period_text.to_s.split(':').last.split('~')
    Rails.logger.debug "period text #{period_text.first} #{period_text.last}"
    @start_date = Date.strptime(period_text.first, '%Y-%m-%d')
    @end_date = Date.strptime(period_text.last, '%Y-%m-%d')
    @start_date..@end_date
  end
end
