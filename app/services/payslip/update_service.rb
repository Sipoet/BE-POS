class Payslip::UpdateService < ApplicationService
  include NestedAttributesMatchup
  def execute_service
    payslip = Payslip.find(params[:id])
    raise RecordNotFound.new(params[:id], Payslip.model_name.human) if payslip.nil?

    if payslip_save?(payslip)
      render_json(PayslipSerializer.new(payslip), { status: :ok })
    else
      render_error_record(payslip)
    end
  end

  def payslip_save?(payslip)
    ApplicationRecord.transaction do
      build_lines(payslip)
      update_attribute(payslip)
      calculate_payslip(payslip)
      payslip.save!
    end
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def calculate_payslip(payslip)
    PayslipCalculator.new(payslip).calculate_and_filled
  end

  def build_lines(payslip)
    permitted_params = params.required(:data)
                             .required(:relationships)
                             .required(:payslip_lines)
                             .permit(data: [:type, :id, { attributes: %i[group payroll_type_id description
                                                                         amount] }])
    return if permitted_params.blank? || permitted_params[:data].blank?

    edit_attributes(permitted_params[:data], payslip.payslip_lines)
  end

  def update_attribute(payslip)
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(:start_date, :end_date, :notes, :sick_leave,
                                     :known_absence,
                                     :unknown_absence,
                                     :paid_time_off,
                                     :overtime_hour,
                                     :late)
    payslip.attributes = permitted_params
  end
end
