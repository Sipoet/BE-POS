class Ipos::Account < ApplicationRecord
  self.table_name = 'tbl_perkiraan'
  self.primary_key = 'kodeacc'

  alias_attribute :id, :kodeacc
  alias_attribute :updated_at, :dateupd
  alias_attribute :code, :kodeacc
  alias_attribute :name, :namaacc

  validates :kodeacc, presence: true
  validates :kelompok, presence: true
  validates :tipe, presence: true
  validates :namaacc, presence: true
  validates :parentacc, presence: true, if: :type_detail?
  validates :matauang, presence: true
  validates :kasbank, presence: true
  validates :defmuutm, presence: true
  validates :dateupd, presence: true

  def type_detail?
    tipe == 'D'
  end

  def type_header?
    tipe == 'H'
  end
end
