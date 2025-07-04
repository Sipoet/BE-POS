class CreatePurchaseHeaders < ActiveRecord::Migration[7.1]
  def change
    create_table :purchase_headers do |t|
      t.integer :supplier_id, null: false
      t.boolean :is_consignment, null: false, default: false
      t.date :transaction_date, null: false
      t.datetime :shipping_at
      t.integer :location_id, null: false
      t.string :supplier_transaction_number
      t.integer :contrabon_id
      t.decimal :subtotal
      t.decimal :header_discount_amount
      t.decimal :tax_amount
      t.integer :tax_type
      t.decimal :grandtotal
      t.decimal :shipping_cost
      t.timestamps
    end
  end
end
