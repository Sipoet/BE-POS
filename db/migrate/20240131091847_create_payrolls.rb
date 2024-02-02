class CreatePayrolls < ActiveRecord::Migration[7.1]
  def change
    create_table :payrolls do |t|
      t.integer :name, null: false
      t.decimal :base_salary, null: false
      t.decimal :overtime_paid, null: false # overtime paid per hour
      t.string :begin_schedule1, null: false
      t.string :end_schedule1, null: false
      t.string :begin_schedule2, null: false
      t.string :end_schedule2, null: false
      t.decimal :positional_incentive, null: false # tunjangan jabatan
      t.decimal :attendance_incentive, null: false #uang kerajinan
      t.integer :paid_time_off, null: false # paid time off per month
      t.timestamps
    end
  end
end
