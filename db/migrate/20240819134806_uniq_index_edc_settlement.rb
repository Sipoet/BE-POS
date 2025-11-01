class UniqIndexEdcSettlement < ActiveRecord::Migration[7.1]
  def change
    add_index :edc_settlements, %i[cashier_session_id payment_provider_id payment_type_id terminal_id],
              unique: true
  end
end
