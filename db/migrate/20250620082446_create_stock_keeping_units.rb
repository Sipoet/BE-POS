class CreateStockKeepingUnits < ActiveRecord::Migration[7.1]
  def change
    create_table :stock_keeping_units do |t|
      t.integer :product_id, null: false, index: true
      t.references :document, polymorphic: true, null: false
      t.string :barcode, null: false
      t.date :expired_date
      t.date :purchase_date
      t.date :production_date
      t.decimal :sell_price, null: false, default: 0
      t.decimal :cogs, null: false, default: 0
      t.string :uom
      t.integer :option1_id
      t.integer :option2_id
      t.integer :option3_id
      t.string :serial_number # masih ragu
      t.timestamps
    end
    add_foreign_key :stock_keeping_units, :products, column: :product_id
    add_foreign_key :stock_keeping_units, :tags, column: :option1_id
    add_foreign_key :stock_keeping_units, :tags, column: :option2_id
    add_foreign_key :stock_keeping_units, :tags, column: :option3_id
  end
end
