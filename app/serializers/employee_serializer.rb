class EmployeeSerializer
  include JSONAPI::Serializer
  attributes :code, :name,:start_working_date,
  :end_working_date, :description, :bank_register_name,
  :id_number,:contact_number, :address, :image_code,
  :bank, :bank_account,:status, :debt, :shift,
  :created_at, :updated_at

  belongs_to :role, if: Proc.new { |record, params| params[:include].include?('role') rescue false }
  belongs_to :payroll, if: Proc.new { |record, params| params[:include].include?('payroll') rescue false }

end
