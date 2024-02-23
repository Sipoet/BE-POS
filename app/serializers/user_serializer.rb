class UserSerializer
  include JSONAPI::Serializer
  attributes :email, :username

  belongs_to :role

  cache_options store: Rails.cache, namespace: 'jsonapi-serializer', expires_in: 1.hour
end
