class TableColumnSerializer
  include JSONAPI::Serializer

  set_type :table_column
  set_id :name

  attributes  :name, :type, :humanize_name, :can_filter, :class_name,
              :can_sort, :client_width, :input_options, :excel_width, :alias_name
end
