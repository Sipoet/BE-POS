class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  TABLE_HEADER = []

  def self.datatable_column(klass,key,type, width: 25,attribute_key: nil,path: nil, sort_key: nil,can_filter: true)
    Datatable::TableColumn.new(
      humanize_name: self.human_attribute_name(key.to_s.split('.').last.to_sym),
      type: type,
      name: key,
      width: width,
      attribute_key: attribute_key,
      path: path,
      can_filter: can_filter,
      sort_key: sort_key)
  end
end
