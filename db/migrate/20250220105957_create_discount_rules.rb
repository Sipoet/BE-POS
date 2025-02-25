class CreateDiscountRules < ActiveRecord::Migration[7.1]
  def change
    create_table :discount_rules do |t|
      t.integer :priority, null: false, default: 1
      t.string :name, null: false
      t.integer :use_type, null: false, default: 0
      t.integer :rule_type, null: false, default: 0
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.boolean :status, null: false, default: false
      t.integer :min_quantity, null: false, default: 1
      t.integer :min_sales_amount, null: false, default: 1
      t.decimal :variable1
      t.decimal :variable2
      t.decimal :variable3
      t.decimal :variable4
      t.decimal :variable5
      t.timestamps
    end

    add_index :discount_rules, :name, unique: true
  end
end
