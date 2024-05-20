require 'yaml'
class ActivityLogSerializer
  include JSONAPI::Serializer

  attributes :item_type,
              :item_id,
              :event,
              :created_at

  attribute :actor do |obj|
    obj.user.try(:username)
  end

  attribute :description do |obj|
    description = []
    item_klass = obj.item_klass
    obj.description.each do |attribute_key, value|
      description << "#{item_klass.human_attribute_name(attribute_key)} dari #{value[0]} ke #{value[1]}"
    end
    description.join("\n")
  end



end
