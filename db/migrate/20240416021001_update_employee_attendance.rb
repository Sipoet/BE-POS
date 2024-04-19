class UpdateEmployeeAttendance < ActiveRecord::Migration[7.1]
  def change
    remove_index :employee_attendances, [:employee_id,:date], unique: true
    add_index :employee_attendances, [:employee_id,:start_time], unique: true
  end

  def down
    remove_index :employee_attendances, [:employee_id,:start_time], unique: true
    add_index :employee_attendances, [:employee_id,:date], unique: true
  end
end
