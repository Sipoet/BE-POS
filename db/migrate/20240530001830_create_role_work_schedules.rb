class CreateRoleWorkSchedules < ActiveRecord::Migration[7.1]
  def change
    create_table :role_work_schedules do |t|
      t.string :group_name, null: false
      t.date :begin_active_at, null: false
      t.date :end_active_at, null: false
      t.integer :level, null: false, default: 1
      t.integer :shift, null: false
      t.string :begin_work, null: false
      t.string :end_work, null: false
      t.integer :day_of_week, null: false
      t.integer :role_id, null: false
      t.timestamps
    end
    add_foreign_key :role_work_schedules, :roles, column: :role_id
    add_index :role_work_schedules, %i[role_id level day_of_week shift]
  end
end
