class ItemSale::TransactionReportService < ApplicationService

  def execute_service
    find_key!
    find_range
    limit = @params.fetch(:limit, 10).to_i
    results = execute_sql(query_report(limit))
    render_json({
      data: results.map { |row| decorate_row(row) },
      meta: {
        group_key: @group_key,
        limit: limit
      }
    })
  end

  private

  def decorate_row(row)
    Result.new(
      quantity: row['quantity'],
      sales_total: row['sales_total'],
      discount_total: row['subtotal'] - row['sales_total'],
      identifier: row['identifier']
    )
  end

  def find_range
    @start_time = @params.fetch(:start_time,Time.now.utc.beginning_of_day).try(:to_time)
    @end_time = @params.fetch(:end_time,Time.now.utc.end_of_day).try(:to_time)
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
      #{Ipos::Item.table_name}.#{key_item_of(@group_key)} AS identifier,
      COALESCE(SUM(#{Ipos::ItemSale.table_name}.harga * #{Ipos::ItemSale.table_name}.jumlah),0) AS subtotal,
      SUM(#{Ipos::ItemSale.table_name}.jumlah) AS quantity,
      SUM(#{Ipos::ItemSale.table_name}.total) AS sales_total
    FROM #{Ipos::ItemSale.table_name}
    INNER JOIN #{Ipos::Item.table_name} on #{Ipos::Item.table_name}.kodeitem = #{Ipos::ItemSale.table_name}.kodeitem
    INNER JOIN #{Ipos::Sale.table_name} on #{Ipos::Sale.table_name}.notransaksi = #{Ipos::ItemSale.table_name}.notransaksi
    WHERE #{Ipos::Sale.table_name}.tanggal between '#{@start_time}' and '#{@end_time}'
    GROUP BY
      #{Ipos::Item.table_name}.#{key_item_of(@group_key)}
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
