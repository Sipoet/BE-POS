class Ipos::OrderInHeader < ApplicationRecord
  self.table_name = 'tbl_pesanhd'
  self.inheritance_column = :tipe
  self.primary_key = 'notransaksi'

  alias_attribute :id, :notransaksi

  belongs_to :supplier, optional: true, foreign_key: :kodesupel, primary_key: :kode
  has_many :purchase_order_items, class_name:'Ipos::PurchaseOrderItem',  foreign_key: 'notransaksi', primary_key: 'notransaksi',dependent: :destroy

  @@list={
    'OB'=> 'Ipos::PurchaseOrder',
    'OKI'=> 'Ipos::ConsignmentInOrder',
    'OJ' => 'Ipos::SalesOrder'
  }
  def self.find_sti_class(obj_type)
    @@list[obj_type].constantize
  end
end
