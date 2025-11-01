class Ipos::Supel < ApplicationRecord
  self.table_name = 'tbl_supel'
  self.inheritance_column = :tipe
  self.primary_key = 'kode'

  alias_attribute :id, :kode
  alias_attribute :code, :kode
  alias_attribute :name, :nama
  alias_attribute :address, :alamat
  alias_attribute :contact, :kontak
  alias_attribute :description, :keterangan
  alias_attribute :account, :norek
  alias_attribute :account_register_name, :atasnama
  alias_attribute :city, :kota

  @@list = {
    'SU' => 'Ipos::Supplier',
    'PL' => 'Ipos::Customer',
    'SE' => 'Ipos::SalesPerson'
  }
  def self.find_sti_class(obj_type)
    @@list[obj_type].constantize
  end
end
