class Datatable::TableColumn
  attr_reader :name, :type, :humanize_name, :width

  def initialize(name:,type:,humanize_name:, width: 25)
    @name = name
    @type = type
    @humanize_name = humanize_name
    @width = width
  end
end
