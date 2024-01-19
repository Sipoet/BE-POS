class Ipos::BeginningBalance < ApplicationRecord
  self.table_name = 'tbl_item_sa'
  self.primary_key = 'iddetailtrs'

  belongs_to :item, class_name:'Ipos::Item', primary_key: 'kodeitem', foreign_key: 'kodeitem'

end
