class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  TABLE_HEADER = []

  def self.datatable_column(klass,key,type, width: 25,attribute_key: nil,path: nil, sort_key: nil)
    Datatable::TableColumn.new(
      humanize_name: self.human_attribute_name(key),
      type: type,
      name: key,
      width: width,
      attribute_key: attribute_key,
      path: path,
      sort_key: sort_key)
  end
end
