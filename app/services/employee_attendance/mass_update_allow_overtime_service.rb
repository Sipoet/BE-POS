class EmployeeAttendance::MassUpdateAllowOvertimeService < ApplicationService
  def execute_service
    extract_params!
    employee_attendances = update_attendance
    render_json(EmployeeAttendanceSerializer.new(employee_attendances, { include: ['employee'] }))
  rescue ValidationError => e
    render_json({ message: e.message }, { status: :conflict })
  end

  private

  def update_attendance
    query = filtered_query
    query.update_all(allow_overtime: @allow_overtime)
    query
  end

  def filtered_query
    query = EmployeeAttendance.where(date: @date)
    query = query.where(employee_id: @employee_ids) if @employee_ids.present?
    query = query.where(shift: @shift) if @shift.present?
    query
  end

  def extract_params!
    permitted_params = params.permit(:shift, :date, :allow_overtime, employee_ids: [])
    @employee_ids = begin
      permitted_params[:employee_ids].map { |value| value.to_i }
    rescue StandardError
      []
    end
    @shift = permitted_params[:shift]
    @date = permitted_params[:date]
    @allow_overtime = permitted_params[:allow_overtime].to_s.downcase == 'true'
    raise ValidationError.new('date invalid') if @date.nil?
  end
end
