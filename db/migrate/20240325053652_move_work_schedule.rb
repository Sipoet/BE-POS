class MoveWorkSchedule < ActiveRecord::Migration[7.1]
  def change
    ApplicationRecord.transaction do
      add_column :work_schedules, :employee_id, :integer
      add_foreign_key :work_schedules, :employees, column: :employee_id
      WorkSchedule.all.each do |row|
        row.update(employee_id: Employee.find_by(payroll_id: row.payroll_id).id)
      end
      change_column :work_schedules, :employee_id, :integer, null: false
      remove_foreign_key :work_schedules, :payrolls
      remove_column :work_schedules, :payroll_id
    end
  end
end
