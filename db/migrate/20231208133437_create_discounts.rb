class CreateDiscounts < ActiveRecord::Migration[7.0]
  def change
    create_table :discounts do |t|
      t.string :code, null: false
      t.string :item_code
      t.string :supplier_code
      t.string :brand_name
      t.string :item_type_name
      t.decimal :discount1, null: false, default: BigDecimal(0)
      t.decimal :discount2, null: false, default: BigDecimal(0)
      t.decimal :discount3, null: false, default: BigDecimal(0)
      t.decimal :discount4, null: false, default: BigDecimal(0)
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.timestamps
    end

    add_index :discounts, :code, unique: true
    add_index :discounts, %i[start_time end_time], order: { start_time: :asc, end_time: :desc }
    add_index :discounts, %i[start_time end_time item_code supplier_code item_type_name brand_name],
              order: { start_time: :asc, end_time: :desc, item_code: :asc, supplier_code: :asc, item_type_name: :asc, brand_name: :asc },
              name: 'active_promotion_idx'
  end
end
