class Ipos::PurchaseReturn < Ipos::ItemInHeader

  belongs_to :supplier, optional: true, foreign_key: :kodesupel, primary_key: :kode
  has_many :purchase_return_items, class_name:'Ipos::PurchaseItem',  foreign_key: 'notransaksi', primary_key: 'notransaksi',dependent: :destroy

  def self.sti_name
    'RB'
  end
end
