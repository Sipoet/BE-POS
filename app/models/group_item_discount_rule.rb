class GroupItemDiscountRule < DiscountRule

  # if value positive then percentage, else then nominal
  alias_attribute :discount_amount1, :variable1
  alias_attribute :discount_amount2, :variable2
  alias_attribute :discount_amount3, :variable3
  alias_attribute :discount_amount4, :variable4
  alias_attribute :discount_amount5, :variable5

  validates :discount_amount1, numericality: {less_than_or_equal_to: 100}
  validates :discount_amount2, numericality: {less_than_or_equal_to: 100}
  validates :discount_amount3, numericality: {less_than_or_equal_to: 100}
  validates :discount_amount4, numericality: {less_than_or_equal_to: 100}
  validates :discount_amount5, numericality: {less_than_or_equal_to: 100}

  def self.sti_name
    1
  end

  (1..5).each do |key|
    define_method("discount#{key}_type") do
      discount_value_type(self.send("discount#{key}"))
    end
  end

  private
  def discount_value_type(amount)
    amount > 0 ? :percentage : :nominal
  end
end
