class Ipos::ItemType < ApplicationRecord
  self.table_name = 'tbl_itemjenis'
  self.primary_key = 'jenis'

  has_closure_tree order: 'jenis'

  alias_attribute :id, :jenis
  alias_attribute :name, :jenis
  alias_attribute :description, :ketjenis


end
