class EmployeeSerializer
  include JSONAPI::Serializer
  attributes :code, :name,:start_working_date,
  :end_working_date, :description,
  :id_number,:contact_number, :address,
  :bank, :bank_account,:status, :debt

  attribute :role do |record|
    RoleSerializer.new(record.role).serializable_hash
  end

end
