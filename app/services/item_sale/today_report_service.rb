class ItemSale::TodayReportService < BaseService

  def execute_service
    key = find_key!
    sales = Sale.where(tanggal: range_today)
    report_result = group_with_key(sales, key)
    data = sort_most(report_result)
    limit = @params.fetch(:limit,10).to_i
    render_json({data: data[0...limit],meta:{group_key: key, limit: limit}})
  end

  private

  def sort_most(report_result)
    report_result.sort { |rowa, rowb| rowb.sales_total <=> rowa.sales_total }
  end

  def range_today
    (Time.now.utc.beginning_of_day)..(Time.now.utc.end_of_day)
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
    group_key = @params[:group_key].to_s.try(:downcase)
    return group_key if %w{brand supplier item_type}.include?(group_key)
    raise 'group key invalid'
  end

  def key_item_of(key)
    case key.to_sym
    when :brand then :merek
    when :supplier then :supplier1
    when :item_type then :jenis
    end
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
