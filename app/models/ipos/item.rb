class Ipos::Item < ApplicationRecord

  self.table_name = 'tbl_item'
  self.primary_key = 'kodeitem'

  belongs_to :brand, optional: true, foreign_key: :merek, primary_key: :merek
  belongs_to :item_type, foreign_key: :jenis, primary_key: :jenis
  belongs_to :supplier, optional: true, foreign_key: :supplier1, primary_key: :kode
  has_one :item_report, foreign_key: :item_code

  paginates_per 20

  after_update do |record|
    Cache.delete("item-serializer:ipos/items/#{record.id}")
  end

  alias_attribute :id, :kodeitem
  alias_attribute :code, :kodeitem
  alias_attribute :name, :namaitem
  alias_attribute :brand_name, :merek
  alias_attribute :item_type_name, :jenis
  alias_attribute :supplier_code, :supplier1
  alias_attribute :sell_price, :hargajual1
  alias_attribute :cogs, :hargapokok
  alias_attribute :uom, :satuan
  alias_attribute :description, :keterangan
  alias_attribute :updated_at, :dateupd
  alias_attribute :created_at, :tanggal_add


end
