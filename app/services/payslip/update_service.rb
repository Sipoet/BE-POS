class Payslip::UpdateService < ApplicationService

  def execute_service
    payslip = Payslip.find(params[:id])
    raise RecordNotFound.new(params[:id],Payslip.model_name.human) if payslip.nil?
    if payslip_save?(payslip)
      render_json(PayslipSerializer.new(payslip),{status: :ok})
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
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  def calculate_payslip(payslip)
    PayslipCalculator.new(payslip).calculate_and_filled
  end

  def build_lines(payslip)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:payslip_lines)
                              .permit(data:[:type,:id, attributes:[:group,:payslip_type,:description,
                                      :amount]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    payslip_lines = payslip.payslip_lines.index_by(&:id)
    permitted_params[:data].each do |line_params|
      payslip_line = payslip_lines[line_params[:id]]
      if payslip_line.present?
        payslip_line.attributes = line_params[:attributes]
        payslip_lines.delete(line_params[:id])
      else
        payslip_line = payslip.payslip_lines.build(line_params[:attributes])
      end
    end
    payslip_lines.values.map(&:mark_for_destruction)
  end

  def update_attribute(payslip)
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(:start_date,:end_date,:notes,:sick_leave
                              :absence,
                              :paid_time_off,
                              :overtime_hour,
                              :late,)
    payslip.attributes = permitted_params
  end

end
