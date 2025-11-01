class Discount::DownloadActiveItemService < ApplicationService
  include ActionView::Helpers::NumberHelper

  def execute_service
    reports = find_reports
    file = generate_file(reports)
    @controller.send_file file
  end

  def find_reports
    now = Time.now
    query = Ipos::ItemPromotion
            .joins(:promotion, :discount)
            .where(promotion: { tgldari: ..now, tglsampai: now.., stsact: true })
            .includes(:item, :discount, promotion: :discount)
            .order(kodeitem: :asc)
    query.to_a.map do |item_promotion|
      item = item_promotion.item
      discount = item_promotion.discount
      discount_amount = calculate_discount(discount, item.sell_price) || 0
      {
        item_code: item_promotion.kodeitem,
        brand_name: item.brand_name,
        item_type_name: item.item_type_name,
        sell_price: item.sell_price,
        discount: discount_format(discount, discount_amount),
        sell_price_after_discount: item.sell_price - discount_amount,
        discount_code: discount.try(:code)
      }
    end
  end

  def calculate_discount(discount, sell_price = 0)
    return nil if discount.nil?
    return sell_price - discount.discount1 if discount.special_price?

    discount_amount = if discount.nominal?
                        discount.discount1
                      elsif discount.percentage?
                        sell_price * discount.discount1 / 100
                      end
    return discount_amount if discount.discount2.blank? || discount.discount2 == 0

    discount_amount = (sell_price - discount_amount) * discount.discount2 / 100
    return discount_amount if discount.discount3.blank? || discount.discount3 == 0

    discount_amount = (sell_price - discount_amount) * discount.discount3 / 100
    return discount_amount if discount.discount4.blank? || discount.discount4 == 0

    (sell_price - discount_amount) * discount.discount4 / 100
  end

  def discount_format(discount, discount_amount)
    return nil if discount.nil?
    return "SP #{money_format(discount.discount1)}" if discount.special_price?

    return money_format(discount_amount) unless discount.percentage?

    [discount.discount1, discount.discount2, discount.discount3, discount.discount4].select { |x| x > 0 }
                                                                                    .map { |percent| "#{percent}%" }
                                                                                    .join(', ')
  end

  def money_format(value)
    number_to_currency(value, unit: 'Rp ', separator: ',', delimiter: '.')
  end

  WHITELIST_COLUMN = %i[item_code brand_name item_type_name sell_price]

  def generate_file(reports)
    column_definitions = Datatable::DefinitionExtractor.new(ItemReport)
                                                       .column_definitions
                                                       .select { |column| WHITELIST_COLUMN.include?(column.name) }

    column_definitions += [
      Datatable::TableColumn.new(:discount, { humanize_name: 'Diskon' }),
      Datatable::TableColumn.new(:sell_price_after_discount, { humanize_name: 'Harga Setelah Diskon', type: 'money' }),
      Datatable::TableColumn.new(:discount_code, { humanize_name: 'Kode Promo' })
    ]
    generator = ExcelGenerator.new
    generator.add_column_definitions(column_definitions)
    generator.set_row_data_type_hash!
    generator.add_data(reports)
    generator.generate("laporan-aktif-diskon-item-#{timestamp}")
  end

  def timestamp
    Time.now.strftime('%y%m%d%H%M%S')
  end
end
