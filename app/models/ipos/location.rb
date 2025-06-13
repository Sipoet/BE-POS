class Ipos::Location < ApplicationRecord
  self.table_name = 'tbl_kantor'
  self.primary_key = 'kodekantor'

  alias_attribute :id, :kodekantor
  alias_attribute :code, :kodekantor
  alias_attribute :name, :namakantor

end
