class Ipos::CashDrawer < ApplicationRecord

  self.table_name = 'tbl_kaslaci'
  self.primary_key = 'notransaksi'

  alias_attribute :id, :notransaksi
end
