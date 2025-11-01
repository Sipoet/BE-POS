class Payroll::ShowService < ApplicationService
  def execute_service
    extract_params
    payroll = Payroll.find(params[:id])
    raise RecordNotFound.new(params[:id], Payroll.model_name.human) if payroll.nil?

    render_json(PayrollSerializer.new(payroll, { fields: @fields, include: @included, params: { include: @included } }))
  end

  private

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Payroll)
    allowed_fields = [:payroll_lines, { payroll_line: [:payroll_type] }]
    permitted_params = params.permit(:include, fields: allowed_fields)
    if permitted_params[:fields].present?
      @fields = allowed_fields.each_with_object({}) do |key, fields|
        if permitted_params[:fields][key].present?
          fields[key] = permitted_params[:fields][key].split(',') & allowed_columns
        end
      end
    end

    return unless permitted_params[:include].present?

    @included = permitted_params[:include].split(',')
  end
end
