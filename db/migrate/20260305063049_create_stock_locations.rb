class CreateStockLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :stock_locations do |t|
      t.string :sku_id
      t.string :rack, null: false
      t.string :location, null: false
      t.decimal :quantity, null: false
      t.string :uom, null: false
      t.timestamps
    end
  end
end
