class Ipos::ConsignmentIn < Ipos::ItemInHeader
  def self.sti_name
    'KI'
  end

  belongs_to :consignment_in_order, class_name: 'Ipos::ConsignmentInOrder', foreign_key: 'notrsorder',
                                    primary_key: 'notransaksi'
  has_many :purchase_items, class_name: 'Ipos::PurchaseItem', foreign_key: 'notransaksi', dependent: :destroy
end
