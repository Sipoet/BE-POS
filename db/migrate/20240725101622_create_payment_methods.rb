class CreatePaymentMethods < ActiveRecord::Migration[7.1]
  def change
    create_table :payment_methods do |t|
      t.integer :payment_provider_id, null: false
      t.integer :payment_type_id, null: false
      t.timestamps
    end

    add_foreign_key :payment_methods, :payment_types, column: :payment_type_id
    add_foreign_key :payment_methods, :payment_providers, column: :payment_provider_id
  end
end
