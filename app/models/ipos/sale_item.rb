class Ipos::SaleItem < ApplicationRecord
  self.table_name = 'tbl_ikdt'
  self.primary_key = ['notransaksi','kodeitem']

  TABLE_HEADER=[
    datatable_column(self,:kodeitem, :link, path:'items',attribute_key: 'item.namaitem'),
    datatable_column(self,:jumlah, :decimal),
    datatable_column(self,:harga, :decimal),
    datatable_column(self,:satuan, :string),
    datatable_column(self,:subtotal, :decimal),
    datatable_column(self,:potongan, :decimal),
    datatable_column(self,:potongan2, :percentage),
    datatable_column(self,:potongan3, :percentage),
    datatable_column(self,:potongan4, :percentage),
    datatable_column(self,:pajak, :decimal),
    datatable_column(self,:total, :decimal),
    datatable_column(self,:updated_at, :datetime),
    datatable_column(self,:sistemhargajual, :string),
    datatable_column(self,:tipepromo, :string),
    datatable_column(self,:jmlgratis, :float),
    datatable_column(self,:itempromo, :string),
    datatable_column(self,:satuanpromo, :string),
    datatable_column(self,:hppdasar, :decimal),
    datatable_column(self,:nobaris, :integer),
    datatable_column(self, :notransaksi, :string),
  ]

  belongs_to :item, foreign_key: :kodeitem, primary_key: :kodeitem
  belongs_to :sale, foreign_key: :notransaksi, primary_key: :notransaksi

  alias_attribute :id, :iddetail
  alias_attribute :updated_at, :dateupd

  def subtotal
    jumlah * harga
  end
end
