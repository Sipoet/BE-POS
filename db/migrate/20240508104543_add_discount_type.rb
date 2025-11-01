class AddDiscountType < ActiveRecord::Migration[7.1]
  def change
    add_column :discounts, :discount_type, :integer, null: false, default: 0
    add_column :discounts, :week1, :boolean, null: false, default: false
    add_column :discounts, :week2, :boolean, null: false, default: false
    add_column :discounts, :week3, :boolean, null: false, default: false
    add_column :discounts, :week4, :boolean, null: false, default: false
    add_column :discounts, :week5, :boolean, null: false, default: false
    add_column :discounts, :week6, :boolean, null: false, default: false
    add_column :discounts, :week7, :boolean, null: false, default: false
    add_column :discounts, :discount_group, :string
  end
end
