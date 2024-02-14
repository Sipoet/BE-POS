class Role::IndexService < ApplicationService

  def execute_service
    extract_params
    @roles = find_roles
    render_json(RoleSerializer.new(@roles,{meta: meta, fields: @fields}))
  end

  def meta
    {
      page: @page,
      per: @per,
      total_pages: @roles.total_pages,
    }
  end

  def extract_params
    permitted_params = @params.permit(:page,:per,:search_text,:order_key,:is_order_asc,fields:[:roles])
    @page = permitted_params.fetch(:page,1).to_i
    @per = permitted_params.fetch(:per,20).to_i
    @search_text = permitted_params[:search_text].to_s
    @order_key = permitted_params[:order_key] if Role::TABLE_HEADER.map(&:name).include?(permitted_params[:order_key])
    @order_value = permitted_params[:is_order_asc].try(:downcase) == 'true' ? :asc : :desc
    @fields = permitted_params[:fields].each_with_object({}){|(key,value),obj| obj[key] = value.split(',').map(&:to_sym)} rescue nil
  end

  def find_roles
    roles = Role.all
      .page(@page)
      .per(@per)
    if @search_text.present?
      roles = roles.where(['name ilike ?',"%#{@search_text}%"])
    end
    if @order_key.present?
      roles = roles.order(@order_key => @order_value)
    else
      roles = roles.order(name: :asc)
    end
    roles
  end
end
