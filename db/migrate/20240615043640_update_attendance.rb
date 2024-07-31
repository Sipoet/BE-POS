class UpdateAttendance < ActiveRecord::Migration[7.1]
  def up
    add_column :employee_attendances, :shift, :integer, null: false, default: 0
    add_column :employee_attendances, :is_late, :boolean, null: false, default: false
    add_column :employee_attendances, :allow_overtime, :boolean, null: false, default: false
    add_index :employee_leaves, [:employee_id, :change_date],name: 'emp_id_change_date_idx'
    seed_attendance_shift_and_late_flag
  end

  def down
    remove_column :employee_attendances, :shift
    remove_column :employee_attendances, :is_late
    remove_column :employee_attendances, :allow_overtime
    remove_index :employee_leaves, name: 'emp_id_change_date_idx'
  end

  private

  def seed_attendance_shift_and_late_flag
    ApplicationRecord.transaction do
      EmployeeAttendance.all.includes(:employee)
                        .group_by{|employee_attendance|employee_attendance.employee.role_id}
                        .each do |role_id, employee_attendances|
        finder = WorkScheduleFinder.new(role_id)
        employee_attendances.group_by{|line|[line.date,line.employee_id]}
                            .each do |(date, employee_id), day_employee_attendances|
          shift = finder.shift_based_attendances(day_employee_attendances)
          work_schedules = finder.work_schedules_based_attendances(day_employee_attendances)
          day_employee_attendances.each.with_index do |employee_attendance, index|
            work_schedule = work_schedules[index]
            is_late = false
            if work_schedule.present?
              schedule_begin_at = schedule_of(employee_attendance.date, work_schedule.begin_work)
              is_late = employee_attendance.start_time > schedule_begin_at
            end
            employee_attendance.update!(shift: shift, is_late: is_late)
          end
        end
      end
    end
  end

  def schedule_of(date, time)
    Time.parse("#{date.iso8601} #{time}")
  end
end
