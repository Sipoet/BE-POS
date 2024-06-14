class ActivityLog::ByUserService < ApplicationService

  def execute_service
    permitted_params = params.permit(:user_id)
    @page = params.fetch(:page,1)
    @limit = params.fetch(:limit,50)
    @versions = Version.where(whodunnit: permitted_params[:user_id])
                      .order(created_at: :desc)
                      .includes(:user, :item)
                      .page(@page)
                      .limit(@limit)
    activity_logs = convert_versions_to_log(@versions)
    render_json(ActivityLogSerializer.new(activity_logs,{meta: meta}))
  end

  def convert_versions_to_log(versions)
    versions.map do |version|
      ActivityLog.from_version(version)
    end
  end

  def meta
    {
      page: @page,
      limit: @limit,
       total_pages: @versions.total_pages
    }
  end
end
