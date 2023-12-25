FactoryBot.define do
  factory :user do
    # The alias allows us to write author instead of
    # association :author, factory: :user
    username {FFaker::Internet.user_name}
    email {FFaker::Internet.email}
    role {0}
    jti {SecureRandom.uuid}
    password {'password'}
    password_confirmation {'password'}
    factory :superadmin do
      # The alias allows us to write author instead of
      # association :author, factory: :user
      role {5}
    end
  end


end
