class CreateDiscountBrands < ActiveRecord::Migration[7.1]
  def change
    create_table :discount_brands do |t|
      t.string :brand_name, null: false
      t.boolean :is_exclude, null: false, default: false
      t.integer :discount_id, null: false
      t.timestamps
    end
    add_foreign_key :discount_brands, :discounts, column: :discount_id
    add_foreign_key :discount_brands, :tbl_itemmerek, column: :brand_name, primary_key: :merek
    ApplicationRecord.transaction do
      Discount.where('brand_name is not null or blacklist_brand_name is not null').each do |discount|
        discount.discount_brands.build(brand_name: discount.brand_name) if discount.brand_name.present?
        if discount.blacklist_brand_name.present?
          discount.discount_brands.build(is_exclude: true,
                                         brand_name: discount.blacklist_brand_name)
        end
        discount.save!
      end
    end
  end
end
