class CreateWorkSchedules < ActiveRecord::Migration[7.1]

  def change
    create_table :work_schedules do |t|
      t.integer :payroll_id, null: false, index: true
      t.integer :shift, null: false
      t.string :begin_work, null: false
      t.string :end_work, null: false
      t.integer :day_of_week, null: false
      t.timestamps
    end
    add_foreign_key :work_schedules, :payrolls, column: :payroll_id
  end

end
