class Role < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:name, :string),
  ]

  def dummy_var
    SecureRandom.uuid
  end
end
