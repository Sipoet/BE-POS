class Payroll::CreateService < ApplicationService

  def execute_service
    payroll = Payroll.new
    if payroll_save?(payroll)
      render_json(PayrollSerializer.new(payroll),{status: :created})
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
    permitted_params[:data].each do |line_params|
      payroll.payroll_lines.build(line_params[:attributes])
    end
  end

  def update_attribute(payroll)
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(:name,:paid_time_off,:description)
    payroll.attributes = permitted_params
  end

end
