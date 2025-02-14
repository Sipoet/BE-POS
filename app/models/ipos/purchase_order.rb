class Ipos::PurchaseOrder < ApplicationRecord
  self.table_name = 'tbl_pesanhd'
  self.primary_key = 'notransaksi'

  alias_attribute :id, :notransaksi

  belongs_to :supplier, optional: true, foreign_key: :kodesupel, primary_key: :kode
  has_many :purchase_order_items, class_name:'Ipos::PurchaseOrderItem',  foreign_key: 'notransaksi', primary_key: 'notransaksi',dependent: :destroy

end
