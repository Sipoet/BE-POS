class Employee < ApplicationRecord
  has_paper_trail
  TABLE_HEADER = [
    datatable_column(self,:name, :string),
    datatable_column(self,:status, :string),
    datatable_column(self,:role_name, :string),
    datatable_column(self,:start_working_date, :date),
    datatable_column(self,:end_working_date, :date),
    datatable_column(self,:id_number, :string),
    datatable_column(self,:contact_number, :string),
    datatable_column(self,:address, :string),
    datatable_column(self,:bank, :string),
    datatable_column(self,:bank_account, :string),
    datatable_column(self,:debt, :decimal),
  ]

  enum :status, {
    inactive: 0 ,
    active: 1
  }

  belongs_to :role

  def generate_code
    code = SecureRandom.alphanumeric(6).upcase
  end

end
