class EmployeeAttendance < ApplicationRecord
  has_paper_trail
  TABLE_HEADER = [
    datatable_column(self,:employee_id, :link,path:'employees',attribute_key: 'employee.name'),
    datatable_column(self,:date, :date),
    datatable_column(self,:start_time, :time, attribute_key:'start_work'),
    datatable_column(self,:end_time, :time, attribute_key:'end_work'),
    datatable_column(self,:shift, :integer),
    datatable_column(self,:is_late, :boolean),
    datatable_column(self,:allow_overtime, :boolean),
    datatable_column(self,:created_at, :datetime),
    datatable_column(self,:updated_at, :datetime),
  ];

  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_valid

  belongs_to :employee

  def start_work
    start_time.strftime('%H:%M')
  end

  def end_work
    end_time.strftime('%H:%M')
  end

  private
  def end_time_valid
    return if (start_time.blank? || end_time.blank?)
    if start_time > end_time
      errors.add(:end_time,:greater_than, count: start_time)
    end
  end
end
