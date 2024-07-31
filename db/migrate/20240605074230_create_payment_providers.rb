class CreatePaymentProviders < ActiveRecord::Migration[7.1]
  def change
    create_table :payment_providers do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :swift_code
      t.string :currency, null: false
      t.string :account_number, null: false
      t.string :account_register_name, null: false

      t.timestamps
    end
  end
end
