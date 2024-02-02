class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  TABLE_HEADER = []

  def self.datatable_column(klass,key,type, width = 25)
    Datatable::TableColumn.new(
      humanize_name: klass.human_attribute_name(key),
      type: type,
      name: key,
      width: width)
  end
end
