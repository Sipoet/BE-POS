class ActivityLog::ByItemService < ApplicationService

  def execute_service
    permitted_params = params.permit(:item_id,:item_type)
    record_klass = find_klass(permitted_params[:item_type])

    record = record_klass.find(permitted_params[:item_id])
    versions = record.versions
    activity_logs = convert_versions_to_log(versions)
    version_associations = VersionAssociation.where(version_id: versions.pluck(:id))
                         .group_by(&:foreign_type)
    version_associations.each do|foreign_type, values|
      record_klass = find_klass(foreign_type)
      records = record_klass.find(values.map(&:foreign_key_id))
      records.each do |line_record|
        activity_logs += convert_versions_to_log(line_record.versions)
      end
    end
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
