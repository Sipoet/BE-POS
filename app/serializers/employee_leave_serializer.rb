class EmployeeLeaveSerializer
  include JSONAPI::Serializer
  attributes :leave_type, :description, :change_shift, :created_at, :updated_at
  %i[date change_date created_at updated_at].each do |key|
    attributes key do |obj|
      obj.send(key)&.iso8601
    end
  end
  belongs_to :employee
end
