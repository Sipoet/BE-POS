Rails.application.config.to_prepare do
  ActiveModel::Type.register :array, CustomArray
end
