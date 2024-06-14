class Ipos::ItemInHeader < ApplicationRecord
  self.table_name = 'tbl_imhd'
  self.inheritance_column = :tipe
  self.primary_key = 'notransaksi'

  alias_attribute :id, :notransaksi

  @@list={
    'BL'=> 'Ipos::Purchase',
    'KNY'=> 'Ipos::ConsignmentIn',
    'IM'=> 'Ipos::ItemIn',
  }
  def self.find_sti_class(obj_type)
    @@list[obj_type].constantize
  end
end
