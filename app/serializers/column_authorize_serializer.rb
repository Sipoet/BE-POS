class ColumnAuthorizeSerializer
  include JSONAPI::Serializer
  attributes :table
  attribute :column do |record|
    record.column.split(',') rescue []
  end
end
