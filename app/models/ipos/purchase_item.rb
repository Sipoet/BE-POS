class Ipos::PurchaseItem < ApplicationRecord
  self.table_name = 'tbl_imdt'
  self.primary_key = 'iddetail'

  TABLE_HEADER=[
    datatable_column(self,:kodeitem, :link, path:'items',attribute_key: 'item.namaitem'),
    datatable_column(self,:jmlpesan, :decimal),
    datatable_column(self,:jumlah, :decimal),
    datatable_column(self,:harga, :decimal),
    datatable_column(self,:sell_price, :decimal),
    datatable_column(self,:satuan, :string),
    datatable_column(self,:subtotal, :decimal),
    datatable_column(self,:potongan, :decimal),
    datatable_column(self,:potongan2, :percentage),
    datatable_column(self,:potongan3, :percentage),
    datatable_column(self,:potongan4, :percentage),
    datatable_column(self,:pajak, :decimal),
    datatable_column(self,:total, :decimal),
    datatable_column(self,:tglexp, :datetime),
    datatable_column(self,:kodeprod, :string),
    datatable_column(self,:updated_at, :datetime),
    datatable_column(self,:hppdasar, :decimal),
    datatable_column(self,:nobaris, :integer),
    datatable_column(self, :notransaksi, :string),
  ]

  alias_attribute :id, :iddetail
  alias_attribute :updated_at, :dateupd

  belongs_to :purchase, class_name:'Ipos::Purchase',  primary_key: 'notransaksi', foreign_key: 'notransaksi'
  belongs_to :item, class_name:'Ipos::Item', primary_key: 'kodeitem', foreign_key: 'kodeitem'

  def sell_price
    item.try(:hargajual1)
  end

  def subtotal
    harga * jumlah
  end
end
