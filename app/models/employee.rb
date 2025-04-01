class Employee < ApplicationRecord
  has_paper_trail ignore: [:id, :created_at, :updated_at]

  enum :status, {
    inactive: 0 ,
    active: 1
  }

  enum :marital_status, {
    single: 0,
    married: 1,
    married_1_child: 2,
    married_2_child: 3,
    married_3_or_more_child: 4
  }

  enum :religion, {
    other: 0,
    catholic: 6,
    christian: 1,
    buddhism: 2,
    hindu: 3,
    islam: 4,
    khonghucu: 5,
  }

  belongs_to :role
  belongs_to :payroll, optional: true

  validates :role, presence: true
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :start_working_date, presence: true
  validate :end_working_date_should_valid
  validates :payroll, presence: true, if: :active?
  validates :shift, presence: true
  validates :religion, presence: true

  has_many :work_schedules, dependent: :destroy
  has_many :employee_day_offs, dependent: :destroy
  accepts_nested_attributes_for :work_schedules, :employee_day_offs, allow_destroy: true

  def generate_code
    self.code = SecureRandom.alphanumeric(6).upcase
  end

  private
  def end_working_date_should_valid
    if end_working_date.present? && end_working_date < start_working_date
      errors.add(:end_working_date,:greater_than, count: start_working_date.strftime('%d/%m/%y'))
    end
  end

end
