class DiscountBrandSerializer
  include JSONAPI::Serializer
  attributes :brand_name, :is_exclude

  belongs_to :brand, set_id: :brand_name, id_method_name: :brand_name,serializer: Ipos::BrandSerializer
end
