class UserSerializer
  include JSONAPI::Serializer
  attributes :email, :username, :last_sign_in_at, :current_sign_in_at

  belongs_to :role

  cache_options store: Rails.cache, namespace: 'serializer', expires_in: 1.hour
end
