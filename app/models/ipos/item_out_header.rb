class Ipos::ItemOutHeader < ApplicationRecord
  self.table_name = 'tbl_ikhd'
  self.inheritance_column = :tipe
  self.primary_key = 'notransaksi'

  alias_attribute :id, :notransaksi

  @@list={
    'KSR'=> 'Ipos::Sale',
    'KSRP'=> 'Ipos::Sale',
    'JL'=> 'Ipos::Sale',
    'IK'=> 'Ipos::ItemOut',
    'RJ' => 'Ipos::SaleReturn',
  }
  def self.find_sti_class(obj_type)
    @@list[obj_type].constantize
  rescue => e
    raise e
  end
end
