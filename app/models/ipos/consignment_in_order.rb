class Ipos::ConsignmentInOrder < Ipos::OrderInHeader
  belongs_to :supplier, class_name: 'Ipos::Supplier', foreign_key: 'kodesupel', primary_key: 'kode'
  has_one :consignment_in, class_name: 'Ipos::ConsignmentIn', foreign_key: 'notrsorder', primary_key: 'notransaksi'
  def self.sti_name
    'OKI'
  end
end
