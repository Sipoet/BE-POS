class CreateEmployeeDayOffs < ActiveRecord::Migration[7.1]
  def up
    create_table :employee_day_offs do |t|
      t.integer :day_of_week, null: false
      t.integer :active_week, default: 0, null: false
      t.integer :employee_id, null: false
      t.timestamps
    end
    add_foreign_key :employee_day_offs, :employees, column: :employee_id
    seed_day_off
  end

  def down
    remove_foreign_key :employee_day_offs, column: :employee_id
    drop_table :employee_day_offs
  end

  private
  def seed_day_off
    Employee.all.each do |employee|
      work_schedules = employee.work_schedules
      next if work_schedules.blank?
      odd_week = (1..7).to_a
      even_week = (1..7).to_a
      work_schedules.each do |work_schedule|
        if work_schedule.odd_week?
          odd_week.delete(work_schedule.day_of_week)
        elsif work_schedule.even_week?
          even_week.delete(work_schedule.day_of_week)
        elsif work_schedule.all_week?
          odd_week.delete(work_schedule.day_of_week)
          even_week.delete(work_schedule.day_of_week)
        end
      end
      active_week = nil
      day_of_week = nil
      if odd_week.present?
        active_week = :odd_week
        day_of_week = odd_week.first
      elsif even_week.present?
        active_week = :even_week
        day_of_week = even_week.first
      end
      if active_week.present?
        EmployeeDayOff.create!(
          active_week: active_week,
          day_of_week: day_of_week,
          employee: employee
        )
      end
    end
  end
end
