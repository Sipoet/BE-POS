class CreateDiscountGroupItems < ActiveRecord::Migration[7.1]
  def change
    create_table :discount_group_items do |t|
      t.string :item_code, null: false
      t.integer :discount_rule_id, null: false
      t.integer :priority, null: false, default: 1
      t.boolean :is_active, null: false, default: false
      t.timestamps
    end

    add_foreign_key :discount_group_items, :discount_rules, column: :discount_rule_id
    add_foreign_key :discount_group_items, 'tbl_item', column: :item_code, primary_key: :kodeitem
    add_index :discount_group_items,[:item_code,:priority], where: 'is_active = true', unique: true,name: 'dg_prio_idx'
  end
end
