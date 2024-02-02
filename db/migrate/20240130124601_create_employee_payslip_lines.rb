class CreateEmployeePayslipLines < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_payslip_lines do |t|
      t.integer :employee_payslip_id, null: false, index: true
      t.integer :group, null: false
      t.integer :type
      t.string :description, null: false
      t.decimal :amount, null: false
      t.timestamps
    end
    add_foreign_key :employee_payslip_lines, :employee_payslips, column: :employee_payslip_id
    add_index :employee_payslip_lines, [:employee_payslip_id,:type], name: 'emp_pay_line_idx'
  end
end
