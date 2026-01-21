class Ipos::PurchaseOrder < Ipos::OrderInHeader
  has_one :purchase, class_name: 'Ipos::Purchase', foreign_key: 'notrsorder'
  belongs_to :supplier, class_name: 'Ipos::Supplier', foreign_key: 'kodesupel', primary_key: 'kode'

  def self.sti_name
    'OB'
  end
end
