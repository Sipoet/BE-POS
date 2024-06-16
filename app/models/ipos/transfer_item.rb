class Ipos::TransferItem < ApplicationRecord
  self.table_name = 'tbl_itrdt'
  self.primary_key = 'iddetail'

  TABLE_HEADER=[
    datatable_column(self,:kodeitem, :link, path: 'items',attribute_key: 'item.namaitem'),
    datatable_column(self,:jumlah, :decimal),
    datatable_column(self,:cogs, :decimal),
    datatable_column(self,:sell_price, :decimal),
    datatable_column(self,:satuan, :string),
    datatable_column(self,:tglexp, :datetime),
    datatable_column(self,:kodeprod, :string),
    datatable_column(self,:jmlkonversi, :decimal),
    datatable_column(self,:detinfo, :string),
    datatable_column(self,:nobaris, :integer),
    datatable_column(self, 'item.supplier1', :link, path:'suppliers', attribute_key:'supplier.kode'),
    datatable_column(self, 'item.merek', :link, path:'brands', attribute_key:'brand.merek'),
    datatable_column(self, 'item.jenis', :link, path:'item_types', attribute_key:'item_type.jenis'),
    datatable_column(self,:updated_at, :datetime),
    datatable_column(self, :notransaksi, :string),
  ]

  alias_attribute :id, :iddetail
  alias_attribute :updated_at, :dateupd

  belongs_to :transfer, class_name:'Ipos::Transfer',  primary_key: 'notransaksi', foreign_key: 'notransaksi'
  belongs_to :item, class_name:'Ipos::Item', primary_key: 'kodeitem', foreign_key: 'kodeitem'

  def sell_price
    item.try(:hargajual1)
  end

  def cogs
    item.try(:hargapokok)
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
