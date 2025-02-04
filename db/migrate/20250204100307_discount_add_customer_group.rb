class DiscountAddCustomerGroup < ActiveRecord::Migration[7.1]
  def change
    add_column :discounts, :customer_group_code, :string
    add_foreign_key :discounts, :tbl_supelgrup, column: :customer_group_code, primary_key: :kgrup
  end
end
