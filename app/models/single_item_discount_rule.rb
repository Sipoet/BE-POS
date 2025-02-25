class SingleItemDiscountRule < DiscountRule
  # if value positive then percentage, else then nominal
  alias_attribute :discount1, :variable1
  alias_attribute :discount2, :variable2
  alias_attribute :discount3, :variable3
  alias_attribute :discount4, :variable4
  alias_attribute :discount5, :variable5

  validates :discount1, numericality: {less_than_or_equal_to: 100}
  validates :discount2, numericality: {less_than_or_equal_to: 100}
  validates :discount3, numericality: {less_than_or_equal_to: 100}
  validates :discount4, numericality: {less_than_or_equal_to: 100}
  validates :discount5, numericality: {less_than_or_equal_to: 100}

  def self.sti_name
    0
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
