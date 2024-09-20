class Payroll::UpdateService < ApplicationService

  def execute_service
    payroll = Payroll.find(params[:id])
    raise RecordNotFound.new(params[:id],Payroll.model_name.human) if payroll.nil?
    if payroll_save?(payroll)
      render_json(PayrollSerializer.new(payroll),{status: :ok})
    else
      render_error_record(payroll)
    end
  end

  def payroll_save?(payroll)
    ApplicationRecord.transaction do
      build_lines(payroll)
      update_attribute(payroll)
      payroll.save!
    end
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  def build_lines(payroll)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:payroll_lines)
                              .permit(data:[:type,:id, attributes:[:row,:group,:payroll_type_id,:formula,
                                      :description, :variable1, :variable2,
                                      :variable3, :variable4, :variable5]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    payroll_lines = payroll.payroll_lines.index_by(&:id)
    permitted_params[:data].each do |line_params|
      payroll_line = payroll_lines[line_params[:id]]
      if payroll_line.present?
        payroll_line.attributes = line_params[:attributes]
        payroll_lines.delete(line_params[:id])
      else
        payroll_line = payroll.payroll_lines.build(line_params[:attributes])
      end
    end
    payroll_lines.values.map(&:mark_for_destruction)
  end

  def update_attribute(payroll)
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(:name,:paid_time_off,:description)
    payroll.attributes = permitted_params
  end
end
