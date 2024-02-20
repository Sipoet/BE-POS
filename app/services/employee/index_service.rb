class Employee::IndexService < ApplicationService

  def execute_service
    extract_params
    @employees = find_employees
    render_json(EmployeeSerializer.new(@employees,{meta: meta, fields: @fields, include: @included,params:{include: @included}}))
  end

  def meta
    {
      page: @page,
      per: @per,
      total_pages: @employees.total_pages,
    }
  end

  def extract_params
    permitted_params = @params.permit(:page,:per,:search_text,:order_key,:is_order_asc,:include,fields:[:employees,:role])
    @page = permitted_params.fetch(:page,1).to_i
    @per = permitted_params.fetch(:per,20).to_i
    @search_text = permitted_params[:search_text].to_s
    @order_key = permitted_params[:order_key] if Employee::TABLE_HEADER.map(&:name).include?(permitted_params[:order_key])
    @order_value = permitted_params[:is_order_asc].try(:downcase) == 'true' ? :asc : :desc
    @fields = permitted_params[:fields].each_with_object({}){|(key,value),obj| obj[key] = value.split(',').map(&:to_sym)} rescue nil
    @included = permitted_params[:include]
    @included = @included.split(',') if @included.present?
  end

  def find_employees
    employees = Employee.all.includes(:role)
      .page(@page)
      .per(@per)
    if @search_text.present?
      employees = employees.where(['code ilike ? or name ilike ? ']+ Array.new(2,"%#{@search_text}%"))
    end
    if @order_key.present?
      employees = employees.order(@order_key => @order_value)
    else
      employees = employees.order(code: :asc)
    end
    employees
  end
end
