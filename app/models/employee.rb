class Employee < ApplicationRecord
  has_paper_trail
  TABLE_HEADER = [
    datatable_column(self,:code, :string),
    datatable_column(self,:name, :string),
    datatable_column(self,:status, :enum),
    datatable_column(self,:role_id, :link, path:'roles',attribute_key: 'role.name', sort_key:'roles.name'),
    datatable_column(self,:payroll_id, :link, path:'payrolls',attribute_key: 'payroll.name', sort_key:'payrolls.name'),
    datatable_column(self,:shift, :string),
    datatable_column(self,:start_working_date, :date),
    datatable_column(self,:end_working_date, :date),
    datatable_column(self,:id_number, :string),
    datatable_column(self,:contact_number, :string),
    datatable_column(self,:address, :string),
    datatable_column(self,:bank, :string),
    datatable_column(self,:bank_account, :string),
    datatable_column(self,:bank_register_name, :string),
    datatable_column(self,:description, :string),
    datatable_column(self,:debt, :decimal),
    datatable_column(self,:image_code, :image),
    datatable_column(self,:created_at, :datetime),
    datatable_column(self,:updated_at, :datetime),
  ]

  enum :status, {
    inactive: 0 ,
    active: 1
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
