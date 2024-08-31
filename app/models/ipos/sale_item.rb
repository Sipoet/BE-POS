class Ipos::SaleItem < ApplicationRecord
  self.table_name = 'tbl_ikdt'
  self.primary_key = 'iddetail'

  TABLE_HEADER=[
    datatable_column(self,:kodeitem, :link, path:'items',attribute_key: 'item.namaitem'),
    datatable_column(self,'item.namaitem', :string, can_filter: false),
    datatable_column(self,:jumlah, :decimal),
    datatable_column(self,:harga, :decimal),
    datatable_column(self,:satuan, :string),
    datatable_column(self,:subtotal, :money),
    datatable_column(self,:potongan, :decimal),
    datatable_column(self,:potongan2, :percentage),
    datatable_column(self,:potongan3, :percentage),
    datatable_column(self,:potongan4, :percentage),
    datatable_column(self,:pajak, :decimal),
    datatable_column(self,:total, :money),
    datatable_column(self, 'item.supplier1', :link, path: 'suppliers', attribute_key:'supplier.nama'),
    datatable_column(self, 'item.merek', :link, path: 'brands', attribute_key:'brand.ketmerek'),
    datatable_column(self, 'item.jenis', :link, path: 'item_types', attribute_key:'item_type.ketjenis'),
    datatable_column(self, :updated_at, :datetime),
    datatable_column(self, :sistemhargajual, :string),
    datatable_column(self, :tipepromo, :string),
    datatable_column(self, :jmlgratis, :float),
    datatable_column(self, :itempromo, :string),
    datatable_column(self, :satuanpromo, :string),
    datatable_column(self, :hppdasar, :decimal),
    datatable_column(self, :nobaris, :integer),
    datatable_column(self, :notransaksi, :string),
  ]

  belongs_to :item, foreign_key: :kodeitem, primary_key: :kodeitem
  belongs_to :sale, class_name: 'Ipos::ItemOutHeader', foreign_key: :notransaksi, primary_key: :notransaksi

  alias_attribute :id, :iddetail
  alias_attribute :updated_at, :dateupd

  def subtotal
    jumlah * harga
  end

  def item_type_name
    item.jenis
  end

  def supplier_code
    item.supplier1
  end

  def brand_name
    item.merek
  end

  def item_name
    item.namaitem
  end
end
