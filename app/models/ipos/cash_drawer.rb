class Ipos::CashDrawer < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:nama_user, :string),
    datatable_column(self,:shift, :string),
    datatable_column(self,:kas_awal, :decimal),
    datatable_column(self,:kas_masuk, :decimal),
    datatable_column(self,:kas_akhir, :decimal),
    datatable_column(self,:kas_keluar, :decimal),
    datatable_column(self,:wkt_mulai, :datetime),
    datatable_column(self,:wkt_akhir, :datetime),
    datatable_column(self,:login_flag, :boolean),
    datatable_column(self,:nama_komputer, :string),
    datatable_column(self,:notransaksi, :string),
  ]
  self.table_name = 'tbl_kaslaci'
  self.primary_key = 'notransaksi'

  alias_attribute :id, :notransaksi
end
