class CreateEmployeePayrolls < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_payrolls do |t|
      t.integer :employee_id, null: false
      t.integer :payroll_id, null: false
      t.integer :shift, null: false, default: 1
    end
    add_foreign_key :employee_payrolls, :employees, column: :employee_id
    add_foreign_key :employee_payrolls, :payrolls, column: :payroll_id
  end
end
