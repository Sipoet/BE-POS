class HolidaySerializer
  include JSONAPI::Serializer
  attributes :date, :description, :created_at, :updated_at


end
