class Ipos::BeginningBalance < ApplicationRecord
  self.table_name = 'tbl_item_sa'
  self.primary_key = 'iddetailtrs'

  belongs_to :item, class_name: 'Ipos::Item', primary_key: 'kodeitem', foreign_key: 'kodeitem'
  belongs_to :item_report, class_name: 'ItemReport', primary_key: 'item_code', foreign_key: 'kodeitem'
end
