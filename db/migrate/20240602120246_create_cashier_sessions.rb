class CreateCashierSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :cashier_sessions do |t|
      t.date :date, null: false
      t.decimal :total_in, null: false, default: 0
      t.decimal :total_out, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.text :description
      t.timestamps
    end
  end
end
