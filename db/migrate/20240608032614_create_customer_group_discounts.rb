class CreateCustomerGroupDiscounts < ActiveRecord::Migration[7.1]
  def change
    create_table :customer_group_discounts do |t|
      t.date :start_active_date, null: false
      t.date :end_active_date, null: false
      t.integer :level, null: false
      t.string :customer_group_code, null: false
      t.integer :period_type, null: false, default: 0
      t.decimal :discount_percentage, null: false
      t.integer :variable1
      t.integer :variable2
      t.integer :variable3
      t.integer :variable4
      t.integer :variable5
      t.integer :variable6
      t.integer :variable7
      t.timestamps
    end
    add_foreign_key :customer_group_discounts, :tbl_supelgrup, column: :customer_group_code, primary_key: :kgrup
  end
end
