FactoryBot.define do
  factory :supplier, class: 'Ipos::Supplier' do
    # The alias allows us to write author instead of
    kode { SecureRandom.hex(4) }
    tipe { 'SU' }
    nama { FFaker::Company.name }
    alamat { FFaker::Address.street_address }
  end
end
