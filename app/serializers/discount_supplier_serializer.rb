class DiscountSupplierSerializer
  include JSONAPI::Serializer
  attributes :supplier_code, :is_exclude

  belongs_to :supplier, set_id: :supplier_code, id_method_name: :supplier_code
end
