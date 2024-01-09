FactoryBot.define do
  factory :item, class: 'Ipos::Item' do
    kodeitem {SecureRandom.hex(8)}
    association :brand, factory: :brand
    association :item_type, factory: :item_type
    association :supplier, factory: :supplier
    merek{ brand.try(:merek)}
    jenis{ item_type.try(:jenis)}
    supplier1{supplier.try(:kode)}
    tanggal_add{Time.now}
    dateupd{Time.now}
    before(:create) do |record|
      record.merek = record.brand.try(:merek)
      record.supplier1 = record.supplier.try(:kode)
      record.jenis = record.item_type.try(:jenis)
    end
  end


end
