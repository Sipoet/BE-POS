class Ipos::ItemSellUom < ApplicationRecord
  self.table_name = 'tbl_itemsatuanjml'
  self.primary_key = 'iddetail'

  belongs_to :item, foreign_key: :kodeitem, primary_key: :kodeitem, class_name: 'Ipos::Item'

  alias_attribute :barcode, :kodebarcode
  alias_attribute :item_code, :kodeitem
end
