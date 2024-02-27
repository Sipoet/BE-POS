class Datatable::TableColumn
  attr_reader :name, :type, :humanize_name, :width,
              :path,:attribute_key

  def initialize(name:,type:,humanize_name:, width: 25,path:nil,attribute_key:nil, sort_key: nil)
    @name = name
    @type = type
    @humanize_name = humanize_name
    @width = width
    @path = path
    @sort_key = sort_key || @name
    @attribute_key = attribute_key || name
  end
end
