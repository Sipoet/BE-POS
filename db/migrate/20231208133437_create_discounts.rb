class CreateDiscounts < ActiveRecord::Migration[7.0]
  def change
    create_table :discounts do |t|
      t.string :code, null: false
      t.string :item_code
      t.string :supplier_code
      t.string :brand_name
      t.string :item_type
      t.decimal :discount1, null: false
      t.decimal :discount2
      t.decimal :discount3
      t.decimal :discount4
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.timestamps
    end

    add_index :discounts, :code, unique: true
    add_index :discounts, [:start_time,:end_time]
  end
end
