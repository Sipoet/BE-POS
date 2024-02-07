class UpdateDiscountRule < ActiveRecord::Migration[7.1]
  def change
    add_column :discounts, :calculation_type, :integer, null: false, default: 0
    add_column :discounts, :blacklist_supplier_code, :string
    add_column :discounts, :blacklist_item_type_name, :string
    add_column :discounts, :blacklist_brand_name, :string
    add_foreign_key :discounts, :tbl_supel, column: :supplier_code, primary_key: :kode
    add_foreign_key :discounts, :tbl_itemjenis, column: :item_type_name, primary_key: :jenis
    add_foreign_key :discounts, :tbl_itemmerek, column: :brand_name, primary_key: :merek
    add_foreign_key :discounts, :tbl_item, column: :item_code, primary_key: :kodeitem

    add_foreign_key :discounts, :tbl_supel, column: :blacklist_supplier_code, primary_key: :kode
    add_foreign_key :discounts, :tbl_itemjenis, column: :blacklist_item_type_name, primary_key: :jenis
    add_foreign_key :discounts, :tbl_itemmerek, column: :blacklist_brand_name, primary_key: :merek
  end

end
