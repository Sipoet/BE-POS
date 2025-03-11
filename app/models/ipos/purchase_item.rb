class Ipos::PurchaseItem < ApplicationRecord
  self.table_name = 'tbl_imdt'
  self.primary_key = 'iddetail'


  alias_attribute :id, :iddetail
  alias_attribute :updated_at, :dateupd

  belongs_to :purchase, class_name:'Ipos::ItemInHeader',  primary_key: 'notransaksi', foreign_key: 'notransaksi'
  belongs_to :item, class_name:'Ipos::Item', primary_key: 'kodeitem', foreign_key: 'kodeitem'

  def subtotal
    harga * jumlah
  end

  def item_type_name
    item.jenis
  end

  def supplier_code
    item.supplier1
  end

  def brand_name
    item.merek
  end
end
