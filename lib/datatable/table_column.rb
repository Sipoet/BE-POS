class Datatable::TableColumn
  attr_reader :name, :type, :humanize_name, :excel_width,
              :input_options, :can_edit, :edit_key,
              :path, :attribute_key, :can_filter, :can_sort, :filter_key,
              :sort_key, :client_width

  def initialize(name, options = {})
    @name = name
    @type = options[:type] || :string
    @humanize_name = options[:humanize_name] || name
    @excel_width = options[:excel_width] || 25
    # client front end UI table width in pixel
    @client_width = options[:client_width] || 100
    @path = options[:path]
    @sort_key = (options[:sort_key] || name).to_sym
    @attribute_key = (options[:attribute_key] || name).to_sym
    @can_filter = options[:can_filter].nil? || options[:can_filter]
    @filter_key = (options[:filter_key] || name).to_sym if @can_filter
    @input_options = options[:input_options]
    @can_sort = options[:can_sort].nil? || options[:can_sort]
    @sort_key = options[:sort_key] || name if @can_sort

    @can_edit = options[:can_edit].nil? ? @can_filter : options[:can_edit]
    return unless @can_edit

    @edit_key = options[:edit_key] || @filter_key
  end

  def id
    @name
  end
end
