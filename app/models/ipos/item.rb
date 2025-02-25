class Ipos::Item < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:kodeitem, :string),
    datatable_column(self,:namaitem, :string),
    datatable_column(self,:supplier1, :link, path:'suppliers', attribute_key:'supplier.kode'),
    datatable_column(self,:jenis, :link, path:'item_types', attribute_key:'item_type.jenis'),
    datatable_column(self,:merek, :link, path:'brands', attribute_key:'brand.merek'),
    datatable_column(self,:satuan, :string),
    datatable_column(self,:hargapokok, :decimal),
    datatable_column(self,:hargajual1, :decimal),
  ]

  self.table_name = 'tbl_item'
  self.primary_key = 'kodeitem'

  belongs_to :brand, optional: true, foreign_key: :merek, primary_key: :merek
  belongs_to :item_type, foreign_key: :jenis, primary_key: :jenis
  belongs_to :supplier, optional: true, foreign_key: :supplier1, primary_key: :kode

  has_many :discount_rules, through: :group_discount_items
  paginates_per 20

  after_update do |record|
    Cache.delete("item-serializer:ipos/items/#{record.kodeitem}")
  end
end
