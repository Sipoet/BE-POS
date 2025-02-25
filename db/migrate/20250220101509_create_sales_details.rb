class CreateSalesDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :sales_details do |t|
      t.integer :product_id, null: false
      t.integer :quantity, null: false
      t.integer :uom_id, null: false
      t.timestamps
    end
  end
end
