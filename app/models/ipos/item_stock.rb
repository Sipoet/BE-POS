class Ipos::ItemStock < ApplicationRecord
  self.table_name = 'tbl_itemstok'
  self.primary_key = %w[kodeitem kantor]

  alias_attribute :item_code, :kodeitem
  alias_attribute :location_code, :kantor
  alias_attribute :quantity, :stok

  belongs_to :item, class_name: 'Ipos::Item', foreign_key: 'kodeitem', primary_key: 'kodeitem'
  belongs_to :location, class_name: 'Ipos::Location', foreign_key: 'kantor', primary_key: 'kodekantor'
end
