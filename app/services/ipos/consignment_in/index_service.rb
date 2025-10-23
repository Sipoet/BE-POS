class Ipos::ConsignmentIn::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @consignment_ins = find_consignment_ins
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::ConsignmentInSerializer.new(@consignment_ins, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @consignment_ins.total_count,
      total_pages: @consignment_ins.total_pages
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::ConsignmentIn)
    allowed_includes = %i[consignment_in purchase_items supplier consignment_in_order]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @query_included = result.query_included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::ConsignmentIn)
  end

  def find_consignment_ins
    consignment_ins = Ipos::ConsignmentIn.all.includes(@query_included)
                                         .page(@page)
                                         .per(@limit)
    if @search_text.present?
      search_query_arr = [
        'tbl_imhd.notransaksi ilike ?',
        'tbl_imhd.kodesupel ilike ?',
        'tbl_imhd.notrsorder ilike ?',
        'tbl_supel.nama ilike ?'
      ]
      consignment_ins = consignment_ins.where([search_query_arr.join(' OR ')] + Array.new(search_query_arr.length,
                                                                                          "%#{@search_text}%"))
                                       .left_outer_joins(:supplier)
    end
    @filters.each do |filter|
      consignment_ins = filter.add_filter_to_query(consignment_ins)
    end
    if @sort.present?
      consignment_ins.order(@sort)
    else
      consignment_ins.order(tanggal: :desc)
    end
  end
end
