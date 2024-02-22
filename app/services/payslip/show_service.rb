class Payslip::ShowService < ApplicationService

  def execute_service
    extract_params
    payslip = Payslip.find(params[:id])
    raise RecordNotFound.new(params[:id],Payslip.model_name.human) if payslip.nil?
    render_json(PayslipSerializer.new(payslip,{fields: @fields, include: @included, params: {include:@included}}))
  end

  private
  def extract_params
    allowed_columns = Payslip::TABLE_HEADER.map(&:name)
    allowed_fields = [:payslip_line]
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
