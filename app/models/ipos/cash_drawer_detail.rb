class Ipos::CashDrawerDetail < ApplicationRecord


  self.table_name = 'tbl_kaslacidt'
  self.primary_key = 'iddetail'

  alias_attribute :id, :iddetail
end
