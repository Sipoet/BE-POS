class CreateSalesHeaders < ActiveRecord::Migration[7.1]
  def change
    create_table :sales_headers do |t|
      t.datetime :transaction_time, null: false
      t.integer :status, null: false
      t.integer :sales_type, null: false, default: 0
      t.timestamps
    end
  end
end
