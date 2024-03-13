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
      build_schedule(payroll)
      update_attribute(payroll)
      payroll.save!
    end
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  def build_schedule(payroll)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:work_schedules)
                              .permit(data:[:type,:id, attributes:[:shift, :begin_work, :end_work,:day_of_week,:active_week]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    work_schedules = payroll.work_schedules.index_by(&:id)
    permitted_params[:data].each do |line_params|
      work_schedule = work_schedules[line_params[:id].to_i]
      if work_schedule.present?
        work_schedule.attributes = line_params[:attributes]
        work_schedules.delete(line_params[:id])
      else
        work_schedule = payroll.work_schedules.build(line_params[:attributes])
      end
    end
    work_schedules.values.map(&:mark_for_destruction)
  end

  def build_lines(payroll)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:payroll_lines)
                              .permit(data:[:type,:id, attributes:[:row,:group,:payroll_type,:formula,
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
