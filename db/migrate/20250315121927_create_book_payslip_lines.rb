class CreateBookPayslipLines < ActiveRecord::Migration[7.1]
  def change
    create_table :book_payslip_lines do |t|
      t.date :transaction_date, null: false
      t.text :description
      t.integer :payroll_type_id, null: false
      t.integer :group, null: false, default: 1
      t.decimal :amount, null: false
      t.integer :employee_id, null: false
      t.integer :payslip_line_id
      t.timestamps
    end
    add_foreign_key :book_payslip_lines, :payroll_types
    add_foreign_key :book_payslip_lines, :employees
    add_foreign_key :book_payslip_lines, :payslip_lines
  end
end
