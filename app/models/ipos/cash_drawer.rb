class Ipos::CashDrawer < ApplicationRecord

  self.table_name = 'tbl_kaslaci'
  self.primary_key = 'notransaksi'

  alias_attribute :id, :notransaksi
  alias_attribute :user_code, :nama_user
  alias_attribute :start_time, :wkt_mulai
  alias_attribute :end_time, :wkt_akhir
  alias_attribute :cash_in, :kas_masuk
  alias_attribute :start_cash, :kas_awal
  alias_attribute :end_cash, :kas_akhir
end
