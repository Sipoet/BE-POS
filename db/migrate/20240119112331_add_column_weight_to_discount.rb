class AddColumnWeightToDiscount < ActiveRecord::Migration[7.1]
  def change
    add_column :discounts, :weight, :integer, null: false, default: 1
  end
end
