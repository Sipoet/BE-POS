class Supplier::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @suppliers = find_suppliers
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(Ipos::SupplierSerializer.new(@suppliers,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @suppliers.total_pages,
      total_rows: @suppliers.total_count,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Supplier)
    allowed_fields = [:supplier]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      table_definitions: @table_definitions)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = result.fields
  end

  def find_suppliers
    suppliers = Ipos::Supplier.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      suppliers = suppliers.where(['kode ilike ? OR nama ilike ?']+ Array.new(2,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      suppliers = suppliers.where(filter.to_query)
    end
    if @sort.present?
      suppliers = suppliers.order(@sort)
    else
      suppliers = suppliers.order(kode: :asc)
    end
    suppliers
  end

end
