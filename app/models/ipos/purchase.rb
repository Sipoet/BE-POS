class Ipos::Purchase < Ipos::ItemInHeader

  has_many :purchase_items, class_name:'Ipos::PurchaseItem', foreign_key: 'notransaksi', primary_key: 'notransaksi',dependent: :destroy
  belongs_to :purchase_order, class_name: 'Ipos::PurchaseOrder', foreign_key: 'notrsorder', primary_key: 'notransaksi'
  belongs_to :supplier, class_name: 'Ipos::Supplier', foreign_key: 'kodesupel', primary_key: 'kode'

  def self.sti_name
    'BL'
  end
end
