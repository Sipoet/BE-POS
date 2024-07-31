class CreatePaymentProviderEdcs < ActiveRecord::Migration[7.1]
  def change
    create_table :payment_provider_edcs do |t|
      t.integer :payment_provider_id, null: false
      t.string :merchant_id, null: false
      t.string :terminal_id, null: false
      t.timestamps
    end
  end
end
