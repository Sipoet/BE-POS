class MonthlyExpenseReport::GroupByValidator < ApplicationModel

  attribute :group_period, :string
  attribute :start_date, :date
  attribute :end_date, :date
  attribute :account_codes, :array, of: :integer, default: []


  validates :group_period, presence: true, inclusion: {in: ['monthly','yearly']}

  validates :start_date, presence: true
  validates :end_date, presence: true



  def accounts
    Ipos::accounts.where(code: account_codes).index_by(&:code)
  end






end
