class Ipos::CustomerGroup < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:kgrup, :string),
    datatable_column(self,:grup, :string),
    datatable_column(self,:potongan, :decimal),
    datatable_column(self,:levelharga, :integer),
    datatable_column(self,:kelipatanpoin, :integer),
  ]
  self.table_name = 'tbl_supelgrup'
  self.primary_key = 'kgrup'

  alias_attribute :id, :kgrup
end
