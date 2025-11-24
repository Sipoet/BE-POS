class Ipos::SaleItem < ApplicationRecord
  self.table_name = 'tbl_ikdt'
  self.primary_key = 'iddetail'

  belongs_to :item, foreign_key: :kodeitem, primary_key: :kodeitem
  belongs_to :sale, class_name: 'Ipos::ItemOutHeader', foreign_key: :notransaksi, primary_key: :notransaksi

  alias_attribute :id, :iddetail
  alias_attribute :updated_at, :dateupd

  def subtotal
    jumlah * harga
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

  def item_name
    item.namaitem
  end

  def transaction_date
    sale.tanggal
  end

  def sale_type
    sale.tipe
  end
end
