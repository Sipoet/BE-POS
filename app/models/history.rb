class History < ApplicationRecord
  self.table_name = 'versions'

  TABLE_HEADER = [
    datatable_column(self,:item_type, :string),
    datatable_column(self,:item_id, :integer),
    datatable_column(self,:event, :string),
    datatable_column(self,:whodunnit, :string),
    datatable_column(self,:object, :string),
    datatable_column(self,:object_changes, :string),
    datatable_column(self,:created_at, :datetime),
  ]

end
