class Ipos::AccountCash < ApplicationRecord
  self.table_name = 'tbl_acckashd'
  self.primary_key = 'notransaksi'
  self.inheritance_column = :tipe

  alias_attribute :id, :notransaksi
  alias_attribute :updated_at, :dateupd

  validates :notransaksi, presence: true
  validates :tipe, presence: true

  has_many :cash_details, class_name: 'Ipos::CashDetail', foreign_key: :notransaksi, dependent: :destroy,
                          inverse_of: :account_cash
  accepts_nested_attributes_for :cash_details, allow_destroy: true

  @@list = {
    'KASO' => 'Ipos::CashOut',
    'KASI' => 'Ipos::CashIn'
  }
  def self.find_sti_class(obj_type)
    @@list[obj_type].constantize
  end
end
