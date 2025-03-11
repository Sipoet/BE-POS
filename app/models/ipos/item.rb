class Ipos::Item < ApplicationRecord

  self.table_name = 'tbl_item'
  self.primary_key = 'kodeitem'

  belongs_to :brand, optional: true, foreign_key: :merek, primary_key: :merek
  belongs_to :item_type, foreign_key: :jenis, primary_key: :jenis
  belongs_to :supplier, optional: true, foreign_key: :supplier1, primary_key: :kode
  paginates_per 20
end
