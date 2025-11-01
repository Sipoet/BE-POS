class Ipos::SaleItem::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @sale_items = find_sale_items
    case @report_type
    when 'xlsx'
      file_excel = generate_excel(@sale_items)
      @controller.send_file file_excel
    when 'json'
      options = {
        meta: meta,
        fields: @fields,
        params: { include: @included },
        include: @included
      }
      render_json(Ipos::SaleItemSerializer.new(@sale_items, options))
    end
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @sale_items.total_count,
      total_pages: @sale_items.total_pages
    }
  end

  def generate_excel(rows)
    generator = ExcelGenerator.new
    column_definitions = @table_definition.column_definitions
    generator.add_column_definitions(column_definitions)
    generator.add_data(rows)
    generator.add_metadata(@filter || {})
    generator.generate('laporan-sales-item')
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::SaleItem)
    allowed_includes = %i[sale_item item sale]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::SaleItem)
    @report_type = (@params[:report_type] || 'json').to_s
    @limit = 5000 if @report_type == 'xlsx'
  end

  def find_sale_items
    sale_items = Ipos::SaleItem.all.includes(@included)
                               .joins(:sale)
    sale_items = if @report_type == 'json'
                   sale_items.page(@page)
                             .per(@limit)
                 else
                   sale_items.page(1)
                             .per(@limit)
                 end
    if @search_text.present?
      search_query_arr = [
        'tbl_item.kodeitem ilike ?',
        'tbl_item.namaitem ilike ?',
        'tbl_item.merek ilike ?',
        'tbl_item.jenis ilike ?',
        'tbl_item.supplier1 ilike ?'
      ]
      sale_items = sale_items.where([search_query_arr.join(' OR ')] + Array.new(search_query_arr.length,
                                                                                "%#{@search_text}%"))
                             .left_outer_joins(:item, :sale)
    end
    @filters.each do |filter|
      sale_items = sale_items.where(filter.to_query)
    end
    if @sort.present?
      sale_items.order(@sort)
    else
      sale_items.order(item_code: :asc)
    end
  end
end
