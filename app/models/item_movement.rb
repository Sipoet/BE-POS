class ItemMovement < ApplicationRecord
  self.table_name = 'item_movements'
  self.primary_key = 'id'
  include MaterializedView

  enum :movement_type,{
    in: 1,
    out: 0
  }

  belongs_to :item, foreign_key: :item_code, primary_key: :kodeitem, class_name:'Ipos::Item'
  belongs_to :item_type, foreign_key: :item_type_name, primary_key: :jenis, class_name:'Ipos::ItemType'
  belongs_to :brand, optional: true, foreign_key: :brand_name, primary_key: :merek, class_name:'Ipos::Brand'
  belongs_to :supplier, optional: true, foreign_key: :supplier_code, primary_key: :kode, class_name:'Ipos::Supplier'
end
