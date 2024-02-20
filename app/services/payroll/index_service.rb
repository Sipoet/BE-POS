class Payroll::IndexService < ApplicationService

  def execute_service
    extract_params
    @payrolls = find_payrolls
    render_json(PayrollSerializer.new(@payrolls,{meta: meta, fields: @fields,params:{include: @included}, include: @included}))
  end

  def meta
    {
      offset: @offset,
      limit: @limit,
      total_pages: (@payrolls.count/@limit.to_f).ceil,
    }
  end

  def extract_params
    allowed_columns = Payroll::TABLE_HEADER.map(&:name)
    allowed_fields = [:payroll, :payroll_line, :work_schedule]
    permitted_params = @params.permit(
      :search_text,:order_key,:is_order_asc, :include,
      fields: allowed_fields,filter: allowed_columns,page:[:offset,:limit])
    @offset = permitted_params.fetch(:page,{}).fetch(:offset,0).to_i
    @limit = permitted_params.fetch(:page,{}).fetch(:limit,20).to_i
    @search_text = permitted_params[:search_text].to_s
    @order_key = permitted_params[:order_key] if allowed_columns.include?(permitted_params[:order_key])
    @included = permitted_params[:include]
    if @included.present?
      @included = @included.split(',') & ['payroll_lines','work_schedules']
    end
    if permitted_params[:filter].present?
      @filter = allowed_columns.each_with_object({}) do |key, filter|
        filter[key] = permitted_params[:filter][key].split(',') if permitted_params[:filter][key].present?
      end
    end
    @order_value = permitted_params[:is_order_asc].try(:downcase) == 'true' ? :asc : :desc
    if permitted_params[:fields].present?
      @fields = allowed_fields.each_with_object({}) do |key, fields|
        fields[key] = permitted_params[:fields][key].split(',') if permitted_params[:fields][key].present?
      end
    end
  end

  def find_payrolls
    payrolls = Payroll.all.includes(@included)
      .offset(@offset)
      .limit(@limit)
    if @search_text.present?
      payrolls = payrolls.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    if @filter.present?
      payrolls = payrolls.where(@filter)
    end
    if @order_key.present?
      payrolls = payrolls.order(@order_key => @order_value)
    else
      payrolls = payrolls.order(name: :asc)
    end
    payrolls
  end

end
