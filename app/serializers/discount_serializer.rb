class DiscountSerializer
  include JSONAPI::Serializer
  attributes :code, :start_time, :end_time, :weight,
             :calculation_type,:created_at,:updated_at,
             :week1, :week2, :week3, :week4, :week5, :week6,
             :week7, :discount_type
  [:discount1, :discount2,:discount3,:discount4].each do |key|
    attribute key do |object|
      object.send(key).to_f
    end
  end

  attribute :item_code do |object|
    filter_text(object.discount_items.included_items.limit(3).map(&:item_code))
  end
  attribute :supplier_code do |object|
    filter_text(object.discount_suppliers.included_suppliers.limit(3).map(&:supplier_code))
  end
  attribute :brand_name do |object|
    filter_text(object.discount_brands.included_brands.limit(3).map(&:brand_name))
  end
  attribute :item_type_name do |object|
    filter_text(object.discount_item_types.included_item_types.limit(3).map(&:item_type_name))
  end

  attribute :blacklist_item_code do |object|
    filter_text(object.discount_items.included_items.limit(3).map(&:item_code))
  end
  attribute :blacklist_supplier_code do |object|
    filter_text(object.discount_suppliers.excluded_suppliers.limit(3).map(&:supplier_code))
  end
  attribute :blacklist_brand_name do |object|
    filter_text(object.discount_brands.excluded_brands.limit(3).map(&:brand_name))
  end
  attribute :blacklist_item_type_name do |object|
    filter_text(object.discount_item_types.excluded_item_types.limit(3).map(&:item_type_name))
  end

  has_many :discount_items, if: Proc.new { |record, params| params[:include].include?('discount_items') rescue false } do |discount|
    discount.discount_items.order(item_code: :asc).includes(:item)
  end
  has_many :discount_item_types, if: Proc.new { |record, params| params[:include].include?('discount_item_types') rescue false } do |discount|
    discount.discount_item_types.order(item_type_name: :asc).includes(:item_type)
  end
  has_many :discount_brands, if: Proc.new { |record, params| params[:include].include?('discount_brands') rescue false } do |discount|
    discount.discount_brands.order(brand_name: :asc).includes(:brand)
  end
  has_many :discount_suppliers, if: Proc.new { |record, params| params[:include].include?('discount_suppliers') rescue false } do |discount|
    discount.discount_suppliers.order(supplier_code: :asc).includes(:supplier)
  end

  def self.filter_text(text_arr)
    text = text_arr.join(', ')
    if text_arr.length < 3
      return text
    end
    return "#{text}, ..."
  end

  # cache_options store: Rails.cache, namespace: 'discount-serializer', expires_in: 1.hour
end
