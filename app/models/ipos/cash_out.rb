class Ipos::CashOut < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:notransaksi, :string),
    datatable_column(self,:nama_pengambil, :string),
    datatable_column(self,:kas_keluar, :decimal),
    datatable_column(self,:keterangan_p, :string),
    datatable_column(self,:iddetail, :string),

  ]
  self.table_name = 'tbl_kaslacidt'
  self.primary_key = 'iddetail'

  alias_attribute :id, :iddetail
end
