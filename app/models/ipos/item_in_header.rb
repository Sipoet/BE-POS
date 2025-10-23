class Ipos::ItemInHeader < ApplicationRecord
  self.table_name = 'tbl_imhd'
  self.inheritance_column = :tipe
  self.primary_key = 'notransaksi'

  belongs_to :supplier, class_name: 'Ipos::Supplier', foreign_key: 'kodesupel', primary_key: 'kode'
  alias_attribute :id, :notransaksi

  @@list = {
    'BL' => 'Ipos::Purchase',
    'KI' => 'Ipos::ConsignmentIn',
    'IM' => 'Ipos::ItemIn',
    'RB' => 'Ipos::PurchaseReturn',
    'RKI' => 'Ipos::ConsignmentInReturn'
  }
  def self.find_sti_class(obj_type)
    @@list[obj_type].constantize
  end

  def supplier_name
    supplier&.name
  end
end
