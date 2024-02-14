class CreatePayrollLines < ActiveRecord::Migration[7.1]
  def change
    create_table :payroll_lines do |t|
      t.integer :payroll_id, null: false, index: true
      t.integer :row, null: false
      t.integer :group, null: false
      t.integer :payroll_type
      t.integer :formula, null: false
      t.string :description, null: false
      t.decimal :variable1
      t.decimal :variable2
      t.decimal :variable3
      t.decimal :variable4
      t.decimal :variable5
      t.timestamps
    end
    add_foreign_key :payroll_lines, :payrolls, column: :payroll_id
  end
end
