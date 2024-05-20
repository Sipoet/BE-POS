class ActivityLog < ApplicationModel

  TABLE_HEADER = [
    datatable_column(self,:item_type, :string),
    datatable_column(self,:item_id, :integer),
    datatable_column(self,:event, :string),
    datatable_column(self,:actor, :link),
    datatable_column(self,:description, :string),
    datatable_column(self,:created_at, :datetime),
  ]

  attr_accessor :item_type, :item_id, :event, :id,
                :user_id, :description, :created_at

  def user
    return nil if user_id.nil?
    @user ||= User.find(user_id.to_i) rescue nil
  end


  def user=(value)
    @user = value
    user_id = value.try(:id)
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
    activity_log.user_id = version.whodunnit.present? ? version.whodunnit.to_i : nil
    activity_log.created_at = version.created_at
    activity_log
  end
end
