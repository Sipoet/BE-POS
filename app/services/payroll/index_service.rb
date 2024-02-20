class Payroll::IndexService < ApplicationService

  def execute_service
    extract_params
    @payrolls = find_payrolls
    render_json(PayrollSerializer.new(@payrolls,{meta: meta, fields: @fields}))
  end

  def meta
    {
      page: @page,
      per: @per,
      total_pages: @payrolls.total_pages,
    }
  end

  def extract_params
    allowed_columns = Payroll::TABLE_HEADER.map(&:name)
    allowed_fields = [:payroll,:payroll_line]
    permitted_params = @params.permit(
      :page,:per,:search_text,:order_key,:is_order_asc,
      fields: allowed_fields,filter: allowed_columns)
    @page = permitted_params.fetch(:page,1).to_i
    @per = permitted_params.fetch(:per,20).to_i
    @search_text = permitted_params[:search_text].to_s
    @order_key = permitted_params[:order_key] if allowed_columns.include?(permitted_params[:order_key])
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
    payrolls = Payroll.all
      .page(@page)
      .per(@per)
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
