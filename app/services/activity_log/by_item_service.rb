class ActivityLog::ByItemService < ApplicationService

  def execute_service
    permitted_params = params.permit(:item_id,:item_type)
    versions = Version.where(permitted_params)
                      .includes(:user, :item)
                      .order(created_at: :desc)
    activity_logs = convert_versions_to_log(versions)
    acc_version_ids = VersionAssociation.where(foreign_type: permitted_params[:item_type],
                                               foreign_key_id: permitted_params[:item_id])
                         .pluck(:version_id)
    acc_versions = Version.find(acc_version_ids) rescue []
    activity_logs += convert_versions_to_log(acc_versions)
    activity_logs.sort!{|a,b|b.created_at <=> a.created_at}
    render_json(ActivityLogSerializer.new(activity_logs,{meta: meta}))
  end

  def convert_versions_to_log(versions)
    versions.map do |version|
      ActivityLog.from_version(version)
    end
  end

  def find_klass(type_str)
    type_str.classify.constantize
  end

  def meta
    {
      page:1,
      limit: 9_999_999,
      total_pages: 1
    }
  end

end
