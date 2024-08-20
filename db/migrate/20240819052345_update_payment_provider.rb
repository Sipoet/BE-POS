class UpdatePaymentProvider < ActiveRecord::Migration[7.1]
  def change
    rename_column :payment_providers, :code, :bank_or_provider
    add_column :payment_providers, :status, :integer, default: 0, null: false
  end
end
