class Ipos::FormatTransaction < ApplicationRecord
  self.table_name = 'tbl_formatnotr'
  self.primary_key = ['trid','kantor']

end
