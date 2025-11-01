class Ipos::FormatTransaction < ApplicationRecord
  self.table_name = 'tbl_formatnotr'
  self.primary_key = %w[trid kantor]
end
