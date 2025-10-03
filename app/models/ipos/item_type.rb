class Ipos::ItemType < ApplicationRecord

  self.table_name = "tbl_itemjenis"
  self.primary_key = 'jenis'

  alias_attribute :id, :jenis
  alias_attribute :name, :jenis
  alias_attribute :description, :ketjenis

  has_closure_tree order: 'jenis'
end
