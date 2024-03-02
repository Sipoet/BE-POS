class FileStoreSerializer
  include JSONAPI::Serializer
  attributes :code, :filename, :expired_at
end
