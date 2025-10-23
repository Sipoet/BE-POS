class Ipos::Transfer < ApplicationRecord
  self.table_name = 'tbl_itrhd'
  self.primary_key = 'notransaksi'

  has_many :transfer_items, class_name: 'Ipos::TransferItem', foreign_key: 'notransaksi', primary_key: 'notransaksi',
                            dependent: :destroy

  alias_attribute :updated_at, :dateupd

  belongs_to :office, class_name: 'Ipos::Location', foreign_key: 'kodekantor', primary_key: 'kodekantor'
  belongs_to :source_office, class_name: 'Ipos::Location', foreign_key: 'kantordari', primary_key: 'kodekantor'
  belongs_to :destination_office, class_name: 'Ipos::Location', foreign_key: 'kantortujuan', primary_key: 'kodekantor'
end
