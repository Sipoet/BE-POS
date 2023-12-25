class Supplier < ApplicationRecord
  self.table_name = "tbl_supel"
  self.primary_key = ['kode','tipe']
  default_scope {where(tipe: 'SU')}
end
