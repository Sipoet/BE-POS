class ActivityLog < ApplicationModel
  attr_accessor :item_type, :item_id, :event, :id,
                :user_id, :description, :created_at

  def user
    return nil if user_id.nil?

    @user ||= begin
      User.find(user_id.to_i)
    rescue StandardError
      nil
    end
  end

  def user=(value)
    @user = value
    @user_id = value.try(:id)
  end

  def item_klass
    item_type.try(:classify).try(:constantize)
  end

  def self.from_version(version)
    activity_log = new
    activity_log.id = version.id
    activity_log.item_id = version.item_id
    activity_log.item_type = version.item_type
    activity_log.description = version.changeset
    activity_log.event = version.event
    activity_log.user = version.user
    activity_log.created_at = version.created_at
    activity_log
  end
end
