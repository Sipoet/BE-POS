class User::IndexService < BaseService

  def execute_service
    extract_params
    @users = find_users
    render_json(UserSerializer.new(@users,{meta: meta}))
  end

  private
  def meta
    {
      page: @page,
      per: @per,
      total_pages: @users.total_pages,
    }
  end

  def extract_params
    permitted_params = @params.permit(:page,:per,:search_text,:order_key,:is_order_asc)
    @page = permitted_params.fetch(:page,1).to_i
    @per = permitted_params.fetch(:per,20).to_i
    @search_text = permitted_params[:search_text].to_s
    @order_key = permitted_params[:order_key] if %w{username email}.include?(permitted_params[:order_key])
    @order_value = permitted_params[:is_order_asc].try(:downcase) == 'true' ? :asc : :desc
  end

  def find_users
    users = User.all
      .page(@page)
      .per(@per)
    if @search_text.present?
      users = users.where(['username ilike ? or email ilike ? ']+ Array.new(2,"%#{@search_text}%"))
    end
    if @order_key.present?
      users = users.order(@order_key => @order_value)
    else
      users = users.order(username: :asc)
    end
    users
  end

end
