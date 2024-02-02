class CreateEmployeePayslips < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_payslips do |t|
      t.integer :employee_id, null: false
      t.integer :status, null: false, default: 0
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.datetime :payment_time
      t.decimal :gross_salary, null: false
      t.text :notes
      t.decimal :tax_amount, null: false, default: 0
      t.decimal :nett_salary, null: false
      t.integer :sick_leave, null: false, default: 0
      t.integer :absence, null: false, default: 0
      t.integer :paid_time_off, null: false, default: 0
      t.integer :overtime_hour, null: false, default: 0
      t.integer :late, null: false
      t.timestamps
    end
    add_foreign_key :employee_payslips, :employees, column: :employee_id
  end
end
