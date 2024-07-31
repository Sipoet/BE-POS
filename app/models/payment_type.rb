class PaymentType < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:name, :string),
    datatable_column(self,:created_at, :datetime),
    datatable_column(self,:updated_at, :datetime),
  ]
end
