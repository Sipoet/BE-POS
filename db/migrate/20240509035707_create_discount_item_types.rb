class CreateDiscountItemTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :discount_item_types do |t|
      t.string :item_type_name, null: false
      t.boolean :is_exclude, null: false, default: false
      t.integer :discount_id, null: false
      t.timestamps
    end
    add_foreign_key :discount_item_types, :discounts, column: :discount_id
    add_foreign_key :discount_item_types, :tbl_itemjenis, column: :item_type_name, primary_key: :jenis
    ApplicationRecord.transaction do
      Discount.where('item_type_name is not null or blacklist_item_type_name is not null').each do |discount|
        discount.discount_item_types.build(item_type_name: discount.item_type_name) if discount.item_type_name.present?
        discount.discount_item_types.build(is_exclude: true, item_type_name: discount.blacklist_item_type_name) if discount.blacklist_item_type_name.present?
        discount.save!
      end
    end
  end
end
