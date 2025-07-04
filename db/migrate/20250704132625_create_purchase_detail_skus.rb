class CreatePurchaseDetailSkus < ActiveRecord::Migration[7.1]
  def change
    create_table :purchase_detail_skus do |t|
      t.references :purchase_detail, null: false
      t.references :stock_keeping_unit
      t.decimal :quantity, null: false
      t.string :uom
      t.timestamps
    end
  end
end
