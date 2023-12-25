FactoryBot.define do
  factory :discount do
    # The alias allows us to write author instead of
    code{SecureRandom.hex(4)}
    association :brand, factory: :brand
    association :supplier, factory: :supplier
    association :item, factory: :item
    association :item_type, factory: :item_type
    brand_name{brand.try(:merek)}
    supplier_code{supplier.try(:kode)}
    item_code{item.try(:kodeitem)}
    item_type_name{item_type.try(:jenis)}
    discount1{0}
    discount2{0}
    discount3{0}
    discount4{0}
    start_time {1.month.ago.iso8601}
    end_time {1.month.from_now.iso8601}
    factory :discount_all do
      discount1 {10}
      discount2 {20}
      discount3 {30}
      discount4 {40}
    end

    before(:create) do |record|
      record.brand_name = record.brand.try(:merek)
      record.supplier_code = record.supplier.try(:kode)
      record.item_code = record.item.try(:kodeitem)
      record.item_type_name = record.item_type.try(:jenis)
    end
  end


end
