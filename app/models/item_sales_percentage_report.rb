class ItemSalesPercentageReport < ApplicationRecord
  self.table_name = 'item_sales_percentage_reports'
  self.primary_key = 'item_code'
  TABLE_HEADER = [
    datatable_column(self,:item_code, :link, path:'items',attribute_key: 'item.namaitem'),
    datatable_column(self,:item_name, :string),
    datatable_column(self,:item_type_name, :link, path:'item_types',attribute_key: 'item_type.ketjenis'),
    datatable_column(self,:supplier_code, :link, path:'suppliers', attribute_key: 'supplier.nama'),
    datatable_column(self,:supplier_name, :string),
    datatable_column(self,:brand_name, :link, path:'brands', attribute_key: 'brand.merek'),
    datatable_column(self,:recent_purchase_date, :date),
    datatable_column(self,:is_consignment, :boolean),
    datatable_column(self,:stock_left, :decimal),
    datatable_column(self,:warehouse_stock, :decimal),
    datatable_column(self,:store_stock, :decimal),
    datatable_column(self,:item_out, :integer),
    datatable_column(self,:number_of_purchase, :integer),
    datatable_column(self,:number_of_sales, :integer),
    datatable_column(self,:avg_buy_price, :money),
    datatable_column(self,:sell_price, :money),
    datatable_column(self,:purchase_total, :money),
    datatable_column(self,:sales_total, :money),
    datatable_column(self,:gross_profit, :money),
    datatable_column(self,:percentage_sales, :percentage)
  ].freeze

  belongs_to :item, foreign_key: :item_code, primary_key: :kodeitem, class_name:'Ipos::Item'
  belongs_to :item_type, foreign_key: :item_type_name, primary_key: :jenis, class_name:'Ipos::ItemType'
  belongs_to :brand, optional: true, foreign_key: :brand_name, primary_key: :merek, class_name:'Ipos::Brand'
  belongs_to :supplier, foreign_key: :supplier_code, primary_key: :kode, class_name:'Ipos::Supplier'

  alias_attribute :id, :item_code

  def readonly?
    true
  end

end
