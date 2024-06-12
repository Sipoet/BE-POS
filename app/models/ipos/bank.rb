class Ipos::Bank < ApplicationRecord
  self.table_name = 'tbl_bank'
  self.primary_key = 'kodebank'

  TABLE_HEADER=[
    datatable_column(self,:kodebank, :string),
    datatable_column(self,:namabank, :string),
  ].freeze
end
