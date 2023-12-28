class ItemSale::TodayReportService < BaseService

  def execute_service
    find_key!
    find_range
    limit = @params.fetch(:limit,10).to_i
    results = execute_sql(query_report(limit))
    render_json({
      data: results.map {|row| decorate_row(row) },
      meta: {
        group_key: @group_key,
        limit: limit
      }
    })
  end

  private

  def decorate_row(row)
    Result.new(
      quantity: row['quantity'], sales_total: row['sales_total'], discount_total: row['subtotal'] - row['sales_total'], identifier: row['identifier']
    )
  end

  def sort_most(report_result)
    report_result.sort { |rowa, rowb| rowb.sales_total <=> rowa.sales_total }
  end

  def find_range
    @start_time = @params.fetch(:start_time,Time.now.utc.beginning_of_day).try(:to_time)
    @end_time = @params.fetch(:end_time,Time.now.utc.end_of_day).try(:to_time)
  end

  def group_with_key(sales, key)
    key_item = key_item_of(key)
    grouped_item_sales = ItemSale
      .where(sale: sales)
      .includes(:item)
      .group_by{|item_sale| item_sale.item.try(key_item)}
    grouped_item_sales.each_with_object([]) do |(identifier, item_sales), result|
      result << Result.new(quantity: item_sales.sum(&:jumlah),
      sales_total: item_sales.sum(&:total),
      discount_total: item_sales.sum{|item_sale| (item_sale.jumlah * item_sale.harga) - item_sale.total},
      identifier: identifier)
    end
  end

  def find_key!
    @group_key = @params[:group_key].to_s.try(:downcase)
    raise 'group key invalid' unless %w{brand supplier item_type}.include?(@group_key)

  end

  def key_item_of(key)
    case key.to_sym
    when :brand then :merek
    when :supplier then :supplier1
    when :item_type then :jenis
    end
  end

  def query_report(limit)
    <<~SQL
    SELECT
      #{Item.table_name}.#{key_item_of(@group_key)} AS identifier,
      COALESCE(SUM(#{ItemSale.table_name}.harga * #{ItemSale.table_name}.jumlah),0) AS subtotal,
      SUM(#{ItemSale.table_name}.jumlah) AS quantity,
      SUM(#{ItemSale.table_name}.total) AS sales_total
    FROM #{ItemSale.table_name}
    INNER JOIN #{Item.table_name} on #{Item.table_name}.kodeitem = #{ItemSale.table_name}.kodeitem
    INNER JOIN #{Sale.table_name} on #{Sale.table_name}.notransaksi = #{ItemSale.table_name}.notransaksi
    WHERE #{Sale.table_name}.tanggal between '#{@start_time}' and '#{@end_time}'
    GROUP BY
      #{Item.table_name}.#{key_item_of(@group_key)}
    ORDER BY sales_total DESC
    limit #{limit}
    SQL
  end

  class Result
    attr_reader :quantity, :sales_total, :discount_total, :identifier

    def initialize(quantity:, sales_total:, discount_total:, identifier:)
      @quantity = quantity.to_i
      @sales_total = sales_total.to_f
      @discount_total = discount_total.to_f
      @identifier = identifier
    end
  end
end
