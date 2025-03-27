class ItemWithDiscountSerializer
  include TextFormatter
  include JSONAPI::Serializer
  [:item_code, :item_name, :sell_price,:uom,:warehouse_stock,:store_stock].each do |key|
    attribute key do |obj|
      obj.send(key)
    end
  end
  attribute :discount_desc do |obj|
    discount = obj.discount
    if discount.present?
      discount_desc(discount)
    else
      ''
    end
  end

  attribute :sell_price_after_discount do |obj|
    if obj.discount.present?
      sell_price_after_discount(obj.sell_price,obj.discount)
    else
      obj.sell_price
    end
  end

  def self.sell_price_after_discount(sell_price,discount)
    if discount.percentage?
      [discount.discount1,discount.discount2,discount.discount3,discount.discount4]
          .compact
          .reduce{|sum, n| sum == 0 ? sell_price * (100 - n) / 100.0 : sum * (100 - n) / 100.0}
    elsif discount.nominal?
      sell_price - discount.discount1
    elsif discount.special_price?
      discount.discount1
    else
      sell_price
    end
  end

  def self.discount_desc(discount)
    if discount.percentage?
      'Diskon ' + [discount.discount1,discount.discount2,discount.discount3,discount.discount4]
          .compact
          .select{|disc_percent| disc_percent > 0}
          .map{|disc_percent| "#{disc_percent}%"}
          .join('+')
    elsif discount.nominal?
      "Diskon Rp #{number_format(discount.discount1)}"
    elsif discount.special_price?
      "Special Price Rp #{number_format(discount.discount1)}"
    else
      'Tidak diskon'
    end
  end
end
