class HistorySerializer
  include JSONAPI::Serializer
  attributes :item_type,
              :item_id,
              :event,
              :whodunnit,
              :object,
              :object_changes,
              :created_at
end
