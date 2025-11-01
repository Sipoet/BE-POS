class CreateEmployeeAttendances < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_attendances do |t|
      t.integer :employee_id, null: false
      t.date :date, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.timestamps
    end

    add_foreign_key :employee_attendances, :employees, column: :employee_id
    add_index :employee_attendances, %i[employee_id date], unique: true
  end
end
