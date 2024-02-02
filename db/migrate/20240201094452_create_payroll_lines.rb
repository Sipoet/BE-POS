class CreatePayrollLines < ActiveRecord::Migration[7.1]
  def change
    create_table :payroll_lines do |t|
      t.integer :payroll_id, null: false, index: true
      t.integer :row
      t.integer :group, null: false
      t.integer :type
      t.integer :formula
      t.string :description, null: false
      t.string :variable1
      t.string :variable2
      t.string :variable3
      t.string :variable4
      t.string :variable5
      t.timestamps
    end
    add_foreign_key :payroll_lines, :payrolls, column: :payroll_id
  end
end
