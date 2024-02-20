class CreatePayrolls < ActiveRecord::Migration[7.1]
  def change
    create_table :payrolls do |t|
      t.string :name, null: false
      t.text :description
      t.integer :paid_time_off, null: false # paid time off per month
      t.timestamps
    end
  end
end
