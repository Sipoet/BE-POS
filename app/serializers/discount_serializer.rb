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
    filter_text(object.discount_items.included.limit(10).map(&:value))
  end
  attribute :supplier_code do |object|
    filter_text(object.discount_suppliers.included.limit(10).map(&:value))
  end
  attribute :brand_name do |object|
    filter_text(object.discount_brands.included.limit(10).map(&:value))
  end
  attribute :item_type_name do |object|
    filter_text(object.discount_item_types.included.limit(10).map(&:value))
  end

  attribute :blacklist_item_code do |object|
    filter_text(object.discount_items.excluded.limit(10).map(&:value))
  end
  attribute :blacklist_supplier_code do |object|
    filter_text(object.discount_suppliers.excluded.limit(10).map(&:value))
  end
  attribute :blacklist_brand_name do |object|
    filter_text(object.discount_brands.excluded.limit(10).map(&:value))
  end
  attribute :blacklist_item_type_name do |object|
    filter_text(object.discount_item_types.excluded.limit(10).map(&:value))
  end

  has_many :discount_filters, if: proc { |_record, params|
    begin
      params[:include].include?('discount_filters')
    rescue StandardError
      false
    end
  } do |discount|
    discount.discount_filters.order(filter_key: :asc, value: :asc)
  end

  belongs_to :customer_group, set_id: :customer_group_code, id_method_name: :customer_group_code

  def self.filter_text(text_arr)
    text = text_arr.join(', ')
    return text if text_arr.length < 3

    "#{text}, ..."
  end

  # cache_options store: Rails.cache, namespace: 'discount-serializer', expires_in: 1.hour
end
