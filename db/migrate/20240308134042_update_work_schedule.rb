class UpdateWorkSchedule < ActiveRecord::Migration[7.1]
  def change
    remove_column :work_schedules, :long_shift_per_week
    add_column :work_schedules, :active_week, :integer, null: false, default: 0
  end
end
