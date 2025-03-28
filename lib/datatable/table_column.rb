class Datatable::TableColumn
  attr_reader :name, :type, :humanize_name, :excel_width,
              :input_options, :can_edit, :edit_key,
              :path, :attribute_key, :can_filter,:can_sort,:filter_key,
              :sort_key,:client_width

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
    @can_filter = options[:can_filter].nil? ? true : options[:can_filter]
    if @can_filter
      @filter_key = (options[:filter_key] || name).to_sym
    end
    @input_options = options[:input_options]
    @can_sort = options[:can_sort].nil? ? true : options[:can_sort]
    if @can_sort
      @sort_key = options[:sort_key] || name
    end

    @can_edit = options[:can_edit].nil? ? @can_filter : options[:can_edit]
    if @can_edit
      @edit_key = options[:edit_key] || @filter_key
    end
  end

  def id
    @name
  end
end
