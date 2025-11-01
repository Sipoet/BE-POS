class Ipos::Promotion < ApplicationRecord
  self.table_name = 'tbl_itemdisp'
  self.primary_key = 'iddiskon'
  default_scope { order(iddiskon: :asc) }

  scope :active_today, lambda {
    where(tgldari: ..(Time.now),
          tglsampai: (Time.now)..,
          stsact: true)
  }
  scope :within_range, lambda { |start_time, end_time|
    where(tgldari: ..end_time,
          tglsampai: start_time..)
  }
  scope :active_range, lambda { |start_time, end_time|
    where(tgldari: ..end_time,
          tglsampai: start_time..,
          stsact: true)
  }
  belongs_to :discount, optional: true
  has_many :item_promotions, class_name: 'Ipos::ItemPromotion', foreign_key: 'iddiskon', dependent: :destroy
end
