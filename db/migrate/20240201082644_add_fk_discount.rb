class AddFkDiscount < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :discounts, :tbl_itemjenis, column: :item_type_name, primary_key: :jenis
    add_foreign_key :discounts, :tbl_itemmerek, column: :brand_name, primary_key: :merek
    add_foreign_key :discounts, :tbl_supel, column: :supplier_code, primary_key: :kode
    add_foreign_key :discounts, :tbl_item, column: :item_code, primary_key: :kodeitem
  end
end
