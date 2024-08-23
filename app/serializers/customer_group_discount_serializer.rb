class CustomerGroupDiscountSerializer
  include JSONAPI::Serializer
  attributes :period_type, :discount_percentage, :start_active_date,
             :end_active_date, :level, :variable1, :variable2,
             :variable3, :variable4, :variable5, :variable6,
             :variable7,:created_at ,:updated_at

  belongs_to :customer_group, set_id: :customer_group_code, id_method_name: :customer_group_code
end
