FactoryBot.define do
  factory :item_type, class: 'Ipos::ItemType' do
    # The alias allows us to write author instead of
    jenis {FFaker::Product.product_name}
    ketjenis {FFaker::Lorem.words.join(' ')}
  end


end
