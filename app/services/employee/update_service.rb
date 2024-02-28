class Employee::UpdateService < ApplicationService

  def execute_service
    permitted_params = @params.required(:employee)
                              .permit(:name,:role_id,:start_working_date,
                                      :end_working_date, :description,:payroll_id,
                                      :id_number,:contact_number, :address,
                                      :bank, :bank_account, :status
                                      )
    employee = Employee.find_by(code: params[:code].to_s)
    raise RecordNotFound.new(params[:code],Employee.model_name.human) if employee.nil?
    begin
      ApplicationRecord.transaction do
        if params[:image_path].present?
          employee.image = find_and_save_file(params.permit(:image_path)[:image_path]) || employee.image
        end
        employee.save!
        render_json(EmployeeSerializer.new(employee))
      end
    rescue ActiveRecord::RecordInvalid => e
      render_error_record(employee)
    rescue => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
      render_json({message: e.message},{status: :conflict})
    end
  end

  private

  def find_and_save_file(file_path)
    file = find_temp_file(file_path.to_s)
    FileStore.create!(code: SecureRandom.uuid, filename: file_path, file: file.read)
  end

  def find_temp_file(file_path)
    File.open("#{Rails.root}/tmp/#{file_path}",'rb');
  end

end
