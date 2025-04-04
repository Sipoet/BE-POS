class Ipos::CashDetail < ApplicationRecord

  self.table_name = 'tbl_acckasdt'
  self.primary_key = 'iddetail'

  alias_attribute :id, :iddetail
  alias_attribute :updated_at, :dateupd

  validates :iddetail, presence: true
  validates :notransaksi, presence: true
  validates :nobaris, presence: true,numericality:{greater_than: 0,integer: true}
  validates :kodeacc, presence: true
  validates :matauang, presence: true
  validates :rate, presence: true
  validates :jumlah, presence: true
  validates :dateupd, presence: true
  validates :keterangan, presence: true

  belongs_to :account_cash, class_name: 'Ipos::AccountCash', foreign_key: :notransaksi, inverse_of: :cash_details
end
