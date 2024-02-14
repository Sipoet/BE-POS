class CreatePayrolls < ActiveRecord::Migration[7.1]
  def change
    create_table :payrolls do |t|
      t.integer :name, null: false
      t.string :begin_schedule1, null: false
      t.string :end_schedule1, null: false
      t.string :begin_schedule2, null: false
      t.string :end_schedule2, null: false

      t.integer :paid_time_off, null: false # paid time off per month
      t.timestamps
    end
  end
end
