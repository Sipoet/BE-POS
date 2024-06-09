class Ipos::ItemMeasurementQuantity

  self.table_name = 'tbl_itemsatuanjml'
  self.primary_key= 'iddetail'

  belongs_to :item, class_name:'Ipos::Item', foreign_key:'kodeitem', primary_key:'kodeitem'
end
