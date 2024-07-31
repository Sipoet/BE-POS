class CreateEdcSettlements < ActiveRecord::Migration[7.1]
  def change
    create_table :edc_settlements do |t|
      t.integer :cashier_session_id, null: false
      t.integer :payment_provider_id, null: false
      t.integer :payment_type_id, null: false
      t.string :terminal_id, null: false
      t.string :merchant_id, null: false
      t.decimal :amount, null: false
      t.decimal :diff_amount, null: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end
    add_foreign_key :edc_settlements, :cashier_sessions, column: :cashier_session_id
    add_foreign_key :edc_settlements, :payment_providers, column: :payment_provider_id
    add_foreign_key :edc_settlements, :payment_types, column: :payment_type_id
  end
end
