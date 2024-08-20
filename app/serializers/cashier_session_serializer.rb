class CashierSessionSerializer
  include JSONAPI::Serializer
  attributes :date, :total_in, :total_out,:created_at, :updated_at
end
