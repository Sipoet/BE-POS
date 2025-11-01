class CreateDiscountSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :discount_suppliers do |t|
      t.string :supplier_code, null: false
      t.boolean :is_exclude, null: false, default: false
      t.integer :discount_id, null: false
      t.timestamps
    end
    add_foreign_key :discount_suppliers, :discounts, column: :discount_id
    add_foreign_key :discount_suppliers, :tbl_supel, column: :supplier_code, primary_key: :kode
    ApplicationRecord.transaction do
      Discount.where('supplier_code is not null or blacklist_supplier_code is not null').each do |discount|
        discount.discount_suppliers.build(supplier_code: discount.supplier_code) if discount.supplier_code.present?
        if discount.blacklist_supplier_code.present?
          discount.discount_suppliers.build(is_exclude: true,
                                            supplier_code: discount.blacklist_supplier_code)
        end
        discount.save!
      end
    end
  end
end
