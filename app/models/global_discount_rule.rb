class GlobalDiscountRule < DiscountRule
  # if value positive then percentage, else then nominal
  alias_attribute :discount_amount, :variable1
  alias_attribute :max_nominal_discount, :variable2


  validates :discount_amount, numericality: {less_than_or_equal_to: 100}
  validates :max_nominal_discount, numericality: {greater_than: 0}


  def self.sti_name
    3
  end

  def discount_type
    discount_amount > 0 ? :percentage : :nominal
  end

end
