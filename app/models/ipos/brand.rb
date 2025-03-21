class Ipos::Brand < ApplicationRecord

  self.table_name = 'tbl_itemmerek'
  self.primary_key = 'merek'

  alias_attribute :id, :merek
  alias_attribute :name, :merek
  alias_attribute :description, :ketmerek
end
