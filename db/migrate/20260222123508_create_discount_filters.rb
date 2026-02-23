class CreateDiscountFilters < ActiveRecord::Migration[7.1]
  def change
    create_table :discount_filters do |t|
      t.string :value, null: false
      t.string :filter_key, null: false
      t.boolean :is_exclude, null: false
      t.references :discount, null: false, foreign_key: true
      t.timestamps
    end
    ApplicationRecord.transaction do
      migrate_discount_items
      migrate_discount_suppliers
      migrate_disocunt_brands
      migrate_discount_item_types
      drop_table :discount_items
      drop_table :discount_suppliers
      drop_table :discount_brands
      drop_table :discount_item_types
    end
  end

  private

  def migrate_discount_items
    DiscountItem.all.each do |discount_item|
      DiscountFilter.create!(
        discount_id: discount_item.discount_id,
        filter_key: 'item',
        value: discount_item.item_code,
        is_exclude: discount_item.is_exclude
      )
    end
  end

  def migrate_discount_suppliers
    DiscountSupplier.all.each do |discount_supplier|
      DiscountFilter.create!(
        discount_id: discount_supplier.discount_id,
        filter_key: 'supplier',
        value: discount_supplier.supplier_code,
        is_exclude: discount_supplier.is_exclude
      )
    end
  end

  def migrate_disocunt_brands
    DiscountBrand.all.each do |discount_brand|
      DiscountFilter.create!(
        discount_id: discount_brand.discount_id,
        filter_key: 'brand',
        value: discount_brand.brand_name,
        is_exclude: discount_brand.is_exclude
      )
    end
  end

  def migrate_discount_item_types
    DiscountItemType.all.each do |discount_item_type|
      DiscountFilter.create!(
        discount_id: discount_item_type.discount_id,
        filter_key: 'item_type',
        value: discount_item_type.item_type_name,
        is_exclude: discount_item_type.is_exclude
      )
    end
  end
end
