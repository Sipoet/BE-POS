class Ipos::Supplier < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:kode, :string),
    datatable_column(self,:nama, :string),
  ]
  self.table_name = "tbl_supel"
  self.primary_key = ['kode','tipe']
  default_scope {where(tipe: 'SU')}

  def id
    kode
  end
end
