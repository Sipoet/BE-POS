class DiscountSerializer
  include JSONAPI::Serializer
  attributes :code, :start_time, :end_time, :weight,
             :calculation_type, :created_at, :updated_at,
             :week1, :week2, :week3, :week4, :week5, :week6,
             :week7, :discount_type
  %i[discount1 discount2 discount3 discount4].each do |key|
    attribute key do |object|
      object.send(key).to_f / 100
    end
  end

  attribute :item_code do |object|
    filter_text(object.discount_items.included_items.limit(10).map(&:item_code))
  end
  attribute :supplier_code do |object|
    filter_text(object.discount_suppliers.included_suppliers.limit(10).map(&:supplier_code))
  end
  attribute :brand_name do |object|
    filter_text(object.discount_brands.included_brands.limit(10).map(&:brand_name))
  end
  attribute :item_type_name do |object|
    filter_text(object.discount_item_types.included_item_types.limit(10).map(&:item_type_name))
  end

  attribute :blacklist_item_code do |object|
    filter_text(object.discount_items.excluded_items.limit(10).map(&:item_code))
  end
  attribute :blacklist_supplier_code do |object|
    filter_text(object.discount_suppliers.excluded_suppliers.limit(10).map(&:supplier_code))
  end
  attribute :blacklist_brand_name do |object|
    filter_text(object.discount_brands.excluded_brands.limit(10).map(&:brand_name))
  end
  attribute :blacklist_item_type_name do |object|
    filter_text(object.discount_item_types.excluded_item_types.limit(10).map(&:item_type_name))
  end

  has_many :discount_items, if: proc { |_record, params|
    begin
      params[:include].include?('discount_items')
    rescue StandardError
      false
    end
  } do |discount|
    discount.discount_items.order(item_code: :asc).includes(:item)
  end
  has_many :discount_item_types, if: proc { |_record, params|
    begin
      params[:include].include?('discount_item_types')
    rescue StandardError
      false
    end
  } do |discount|
    discount.discount_item_types.order(item_type_name: :asc).includes(:item_type)
  end
  has_many :discount_brands, if: proc { |_record, params|
    begin
      params[:include].include?('discount_brands')
    rescue StandardError
      false
    end
  } do |discount|
    discount.discount_brands.order(brand_name: :asc).includes(:brand)
  end
  has_many :discount_suppliers, if: proc { |_record, params|
    begin
      params[:include].include?('discount_suppliers')
    rescue StandardError
      false
    end
  } do |discount|
    discount.discount_suppliers.order(supplier_code: :asc).includes(:supplier)
  end

  belongs_to :customer_group, set_id: :customer_group_code, id_method_name: :customer_group_code

  def self.filter_text(text_arr)
    text = text_arr.join(', ')
    return text if text_arr.length < 3

    "#{text}, ..."
  end

  # cache_options store: Rails.cache, namespace: 'discount-serializer', expires_in: 1.hour
end
