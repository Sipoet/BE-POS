class CreateDiscountFilters < ActiveRecord::Migration[7.1]
  def change
    create_table :discount_filters do |t|
      t.integer :discount_id, null: false
      t.integer :filter_type, null: false
      t.integer :operator, null: false
      t.string :value, null: false
      t.timestamps
    end
    add_foreign_key :discount_filters, :discounts, column: :discount_id
  end
end
