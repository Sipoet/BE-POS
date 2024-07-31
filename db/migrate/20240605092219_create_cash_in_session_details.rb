class CreateCashInSessionDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :cash_in_session_details do |t|
      t.integer :user_id, null: false
      t.integer :cashier_session_id, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.decimal :begin_cash, null: false
      t.decimal :cash_in, null: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end
    add_foreign_key :cash_in_session_details, :cashier_sessions, column: :cashier_session_id
    add_foreign_key :cash_in_session_details, :users, column: :user_id
  end
end
