class Ipos::CustomerGroup < ApplicationRecord

  self.table_name = 'tbl_supelgrup'
  self.primary_key = 'kgrup'

  alias_attribute :id, :kgrup
end
