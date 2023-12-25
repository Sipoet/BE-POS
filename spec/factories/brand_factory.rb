FactoryBot.define do
  factory :brand do
    # The alias allows us to write author instead of
    merek {FFaker::Product.brand}
    ketmerek {FFaker::Lorem.words.join(' ')}
  end


end
