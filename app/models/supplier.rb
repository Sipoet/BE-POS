class Supplier < ApplicationRecord
  self.table_name = "tbl_supel"
  default_scope {where(tipe: 'SU')} 
end
