class RedeemItemRule < DiscountRule
  # if value positive then percentage, else then nominal
  alias_attribute :redeem_type, :variable1
  alias_attribute :discount_amount, :variable2
  alias_attribute :redeem_amount, :variable3


  validates :discount_amount, numericality: {less_than_or_equal_to: 100}
  validates :redeem_amount, numericality: {greater_than: 0}, if: :redeem_type_price?
  validates :redeem_type, presence: true, inclusion:{in: [0,1]}

  def self.sti_name
    2
  end

  (1..5).each do |key|
    define_method("discount#{key}_type") do|amount|
      discount_value_type(self.send("discount#{key}"))
    end
  end

  def redeem_type_price?
    redeem_type == 1
  end

  def redeem_type_discount?
    redeem_type == 0
  end

  private

  def discount_value_type(amount)
    amount > 0 ? :percentage : :nominal
  end
end
