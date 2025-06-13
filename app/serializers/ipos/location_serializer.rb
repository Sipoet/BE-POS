class Ipos::LocationSerializer
  include JSONAPI::Serializer
  attributes :code, :name, :cabang, :kodeacc
end
