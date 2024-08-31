class Ipos::PurchaseItem < ApplicationRecord
  self.table_name = 'tbl_imdt'
  self.primary_key = 'iddetail'

  TABLE_HEADER=[
    datatable_column(self,:kodeitem, :link, path:'items',attribute_key: 'item.namaitem'),
    datatable_column(self,:jmlpesan, :decimal),
    datatable_column(self,:jumlah, :decimal),
    datatable_column(self,:harga, :decimal),
    datatable_column(self,:sell_price, :money),
    datatable_column(self,:satuan, :string),
    datatable_column(self,:subtotal, :money),
    datatable_column(self,:potongan, :decimal),
    datatable_column(self,:potongan2, :percentage),
    datatable_column(self,:potongan3, :percentage),
    datatable_column(self,:potongan4, :percentage),
    datatable_column(self,:pajak, :decimal),
    datatable_column(self,:total, :money),
    datatable_column(self,:tglexp, :datetime),
    datatable_column(self,:kodeprod, :string),
    datatable_column(self, 'item.supplier1', :link, path:'suppliers', attribute_key:'supplier.nama'),
    datatable_column(self, 'item.merek', :link, path:'brands', attribute_key:'brand.ketmerek'),
    datatable_column(self, 'item.jenis', :link, path:'item_types', attribute_key:'item_type.ketjenis'),
    datatable_column(self,:updated_at, :datetime),
    datatable_column(self,:hppdasar, :decimal),
    datatable_column(self,:nobaris, :integer),
    datatable_column(self, :notransaksi, :string),
  ]

  alias_attribute :id, :iddetail
  alias_attribute :updated_at, :dateupd

  belongs_to :purchase, class_name:'Ipos::ItemInHeader',  primary_key: 'notransaksi', foreign_key: 'notransaksi'
  belongs_to :item, class_name:'Ipos::Item', primary_key: 'kodeitem', foreign_key: 'kodeitem'

  def sell_price
    item.try(:hargajual1)
  end

  def subtotal
    harga * jumlah
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
end
