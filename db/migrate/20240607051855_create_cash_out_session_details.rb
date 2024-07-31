class CreateCashOutSessionDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :cash_out_session_details do |t|
      t.integer :user_id, null: false
      t.datetime :date, null: false
      t.string :name, null: false
      t.decimal :amount, null: false
      t.text :description
      t.integer :status, null: false
      t.timestamps
    end
  end
end
