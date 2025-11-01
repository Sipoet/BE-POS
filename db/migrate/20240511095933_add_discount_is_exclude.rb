class AddDiscountIsExclude < ActiveRecord::Migration[7.1]
  def change
    add_column :discount_items, :is_exclude, :boolean, null: false, default: false
  end
end
