class AccessAuthorizeSerializer
  include JSONAPI::Serializer
  attributes :controller

  attribute :action do |record|
    record.action.split(',')
  rescue StandardError
    []
  end
end
