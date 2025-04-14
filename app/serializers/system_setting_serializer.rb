class SystemSettingSerializer
  include JSONAPI::Serializer
  attributes :key_name, :created_at, :updated_at, :user_id

  attribute :value do |record|
    value_of(record)
  end

  attribute :value_type do |record|
    value_type_of(record)
  end

  belongs_to :user

  def self.value_type_of(record)
    value_type = JSON.parse(record.value)['value_type'] rescue nil
    return value_type unless value_type.nil?
    value = value_of(record)
    if value.is_a?(String)
      :string
    elsif value.is_a?(Numeric)
      :number
    elsif [true,false].include?(value)
      :boolean
    else
      :json
    end
  end

  def self.value_of(record)
    JSON.parse(record.value)['data'] rescue nil
  end
end
