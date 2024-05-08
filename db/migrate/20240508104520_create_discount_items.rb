class CreateDiscountItems < ActiveRecord::Migration[7.1]
  def change
    create_table :discount_items do |t|
      t.string :item_code, null: false
      t.integer :discount_id, null: false
      t.timestamps
    end

    add_foreign_key :discount_items, :discounts, column: :discount_id
    add_foreign_key :discount_items, :tbl_item, column: :item_code, primary_key: :kodeitem
  end
end
