class DiscountRule < ApplicationRecord

  self.inheritance_column = :rule_type

  enum :use_type, {
    cashier: 0,
    promo_code: 1,
    uniq_voucher: 2
  }
  enum :rule_type,{
    same_item_discount: 0,
    group_item_discount: 1,
    redeem_item: 2,
    global_discount: 3
  }
  enum :status,{
    active: true,
    inactive: false
  }
  validates :name, presence: true
  validates :priority, presence: true, numericality:{integer: true, greater_than: 0}
  validates :use_type, presence: true
  validates :rule_type, presence: true
  validates :status, inclusion: {in: [true, false]}


  def self.find_sti_class(rule_type)
    klass_namespace = rule_type.to_s.classify
    "#{klass_namespace}Rule".constantize
  end
end
