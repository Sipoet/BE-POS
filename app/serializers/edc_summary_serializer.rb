class EdcSummarySerializer
  include JSONAPI::Serializer
  set_id :payment_type_id
  attributes :payment_type_name, :total_in_input, :total_in_system, :status
end
