FactoryBot.define do
  factory :user do
    # The alias allows us to write author instead of
    # association :author, factory: :user
    username {FFaker::Internet.user_name}
    email {FFaker::Internet.email}
    role {:admin}
    jti {SecureRandom.uuid}
    password {'password'}
    password_confirmation {'password'}
    factory :superadmin do
      # The alias allows us to write author instead of
      # association :author, factory: :user
      role {:superadmin}
    end

    factory :admin do
      # The alias allows us to write author instead of
      # association :author, factory: :user
      role {:admin}
    end

    factory :cashier do
      # The alias allows us to write author instead of
      # association :author, factory: :user
      role {:cashier}
    end
  end


end
