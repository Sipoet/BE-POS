class DiscountRuleSerializer
  include JSONAPI::Serializer
  attributes :priority, :name, :use_type, :rule_type, :status, :min_quantity, :min_sales_amount


end
