class CreatePayslipLines < ActiveRecord::Migration[7.1]
  def change
    create_table :payslip_lines do |t|
      t.integer :payslip_id, null: false, index: true
      t.integer :group, null: false
      t.integer :payslip_type, null: false
      t.string :description, null: false
      t.decimal :amount, null: false
      t.timestamps
    end
    add_foreign_key :payslip_lines, :payslips, column: :payslip_id
    add_index :payslip_lines, %i[payslip_id payslip_type], name: 'emp_pay_line_idx'
  end
end
