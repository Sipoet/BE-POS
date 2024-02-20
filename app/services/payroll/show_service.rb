class Payroll::ShowService < ApplicationService

  def execute_service
    extract_params
    payroll = Payroll.find(params[:id])
    raise RecordNotFound.new(params[:id],Payroll.model_name.human) if payroll.nil?
    render_json(PayrollSerializer.new(payroll,{fields: @fields, include: @included}))
  end

  private
  def extract_params
    allowed_columns = Payroll::TABLE_HEADER.map(&:name)
    allowed_fields = [:payroll_line]
    permitted_params = params.permit(:include,fields: allowed_fields, )
    if permitted_params[:fields].present?
      @fields = allowed_fields.each_with_object({}) do |key, fields|
        if permitted_params[:fields][key].present?
          fields[key] = permitted_params[:fields][key].split(',') & allowed_columns
        end
      end
    end

    if permitted_params[:include].present?
      @included = permitted_params[:include].split(',')
    end

  end
end
