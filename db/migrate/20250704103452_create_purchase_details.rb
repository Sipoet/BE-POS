class CreatePurchaseDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :purchase_details do |t|
      t.references :purchase_header, null: false
      t.decimal :quantity, null: false
      t.string :uom, null: false
      t.integer :product_id, null: false
      t.decimal :buy_price, null: false
      t.decimal :discount_amount, null: false
      t.string :discount_desc, null: false
      t.decimal :total, null: false
      t.timestamps
    end

    add_foreign_key :purchase_details, :products, column: :product_id
  end
end
