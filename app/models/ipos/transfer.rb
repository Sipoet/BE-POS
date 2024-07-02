class Ipos::Transfer < ApplicationRecord
  self.table_name = 'tbl_itrhd'
  self.primary_key = 'notransaksi'

  TABLE_HEADER = [
    datatable_column(self, :notransaksi, :string),
    datatable_column(self, :tanggal, :datetime),
    datatable_column(self, :kantordari, :string),
    datatable_column(self, :kantortujuan, :string),
    datatable_column(self, :keterangan, :string),
    datatable_column(self, :totalitem, :decimal),
    datatable_column(self, :user1, :string),
    datatable_column(self, :shiftkerja, :string),
    datatable_column(self, :updated_at, :datetime),
  ]

  has_many :transfer_items, class_name:'Ipos::TransferItem',  foreign_key: 'notransaksi', primary_key: 'notransaksi',dependent: :destroy

  alias_attribute :updated_at, :dateupd

  belongs_to :office, class_name: 'Ipos::Office', foreign_key: 'kodekantor', primary_key: 'kodekantor'
  belongs_to :source_office, class_name: 'Ipos::Office', foreign_key: 'kantordari', primary_key: 'kodekantor'
  belongs_to :destination_office, class_name: 'Ipos::Office', foreign_key: 'kantortujuan', primary_key: 'kodekantor'
end
