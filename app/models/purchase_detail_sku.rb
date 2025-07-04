class PurchaseDetailSku < ApplicationRecord

  belongs_to :purchase_detail
  belongs_to :stock_keeping_unit
end
