class Ipos::AccountSerializer
  include JSONAPI::Serializer
  attributes :code, :name, :parentacc, :matauang, :kasbank
end
