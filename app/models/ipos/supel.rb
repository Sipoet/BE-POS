class Ipos::Supel < ApplicationRecord
  self.table_name = "tbl_supel"
  self.inheritance_column = :tipe
  self.primary_key = ['kode','tipe']

  alias_attribute :id, :kode

  @@list={
    'SU'=> 'Ipos::Supplier',
    'PL'=> 'Ipos::Customer',
    'SE'=> 'Ipos::SalesPerson'
  }
  def self.find_sti_class(obj_type)
    @@list[obj_type].constantize
  end
end
