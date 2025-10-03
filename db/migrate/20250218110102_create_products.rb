class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :supplier_id, null: false
      t.string :supplier_product_code, null: false
      t.string :brand_id, null: false
      t.integer :item_type_id, null: false
      t.string :stock_account, null: false
      t.string :base_uom, null: false
      t.timestamps
    end
    # add_foreign_key :products, :suppliers
  end
end
