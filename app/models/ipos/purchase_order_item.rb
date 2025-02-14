class Ipos::PurchaseOrderItem < ApplicationRecord
  self.table_name = 'tbl_pesandt'
  self.primary_key = 'iddetail'

  belongs_to :purchase_order, class_name:'Ipos::PurchaseOrder',  primary_key: 'notransaksi', foreign_key: 'notransaksi'
  belongs_to :item, class_name:'Ipos::Item', primary_key: 'kodeitem', foreign_key: 'kodeitem'

  def sell_price
    item.try(:hargajual1)
  end

  def subtotal
    harga * jumlah
  end

  def item_type_name
    item.jenis
  end

  def supplier_code
    item.supplier1
  end

  def brand_name
    item.merek
  end
end
