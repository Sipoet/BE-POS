class Ipos::ItemOutHeader < ApplicationRecord
  self.table_name = 'tbl_ikhd'
  self.inheritance_column = :tipe
  self.primary_key = 'notransaksi'

  alias_attribute :id, :notransaksi

  @@list={
    'KSR'=> 'Ipos::Sale',
    'JL'=> 'Ipos::Sale',
    'IK'=> 'Ipos::ItemOut'
  }
  def self.find_sti_class(obj_type)
    @@list[obj_type].constantize
  end
end
