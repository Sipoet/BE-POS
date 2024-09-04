class EdcSummarySerializer
  include JSONAPI::Serializer
  attributes :payment_type_name, :total_in_input, :total_in_system, :status
end
