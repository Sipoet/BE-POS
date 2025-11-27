class Payroll::UpdateService < ApplicationService
  include NestedAttributesMatchup
  def execute_service
    payroll = Payroll.find(params[:id])
    raise RecordNotFound.new(params[:id], Payroll.model_name.human) if payroll.nil?

    if payroll_save?(payroll)
      render_json(PayrollSerializer.new(payroll), { status: :ok })
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
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def build_lines(payroll)
    permitted_params = params.required(:data)
                             .required(:relationships)
                             .required(:payroll_lines)
                             .permit(data: [:type, :id, { attributes: %i[row group payroll_type_id formula
                                                                         description variable1 variable2
                                                                         variable3 variable4 variable5] }])
    return if permitted_params.blank? || permitted_params[:data].blank?

    edit_attributes(permitted_params[:data], payroll.payroll_lines)
  end

  def update_attribute(payroll)
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(:name, :paid_time_off, :description)
    payroll.attributes = permitted_params
  end
end
