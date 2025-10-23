class MonthlyExpenseReport < ApplicationRecord
  self.primary_key = 'date_pk'
  include MaterializedView

  alias_attribute :id, :date_pk
end
