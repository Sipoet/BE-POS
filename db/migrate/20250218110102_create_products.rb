class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :supplier_id, null: false
      t.string :supplier_product_code
      t.string :description, null: false
      t.string :brand_id, null: false
      t.string :item_type_id, null: false
      t.string :stock_account, null: false
      t.string :base_uom, null: false
      t.timestamps
    end
    add_foreign_key :products, :tbl_supel, column: :supplier_id, primary_key: :kode
    add_foreign_key :products, :tbl_itemmerek, column: :brand_id, primary_key: :merek
    add_foreign_key :products, :tbl_itemjenis, column: :item_type_id, primary_key: :jenis
  end
end
