class Discount::DownloadItemService < ApplicationService
  include ActionView::Helpers::NumberHelper
  include DiscountAffectedItem
  def execute_service
    discount = Discount.find_by(id: @params[:id])
    raise ApplicationService::RecordNotFound.new(@params[:id], Discount.name) if discount.nil?

    reports = find_reports(discount)
    file = generate_file(reports, discount)
    @controller.send_file file
  end

  def find_reports(discount)
    item_reports = items_based_discount(discount)
                   .includes(:brand, :supplier, :item_type)
                   .order(item_code: :asc)
    item_reports.map do |item|
      discount_amount = calculate_discount(discount, item.sell_price)
      {
        item_code: item.item_code,
        item_name: item.item_name,
        brand: item.brand,
        item_type: item.item_type,
        supplier: item.supplier,
        sell_price: item.sell_price,
        discount: discount_format(discount, discount_amount),
        sell_price_after_discount: item.sell_price - discount_amount,
        discount_code: discount&.code
      }
    end
  end

  def calculate_discount(discount, sell_price = 0)
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
    return "SP #{money_format(discount.discount1)}" if discount.special_price?

    return money_format(discount_amount) unless discount.percentage?

    [discount.discount1, discount.discount2, discount.discount3, discount.discount4].select { |x| x > 0 }
                                                                                    .map { |percent| "#{percent}%" }
                                                                                    .join(', ')
  end

  def money_format(value)
    number_to_currency(value, unit: 'Rp ', separator: ',', delimiter: '.')
  end

  @@column_definitions = [
    Datatable::TableColumn.new(:item_code, { humanize_name: ItemReport.human_attribute_name(:item_code) },
                               ItemReport),
    Datatable::TableColumn.new(:item_name, { humanize_name: ItemReport.human_attribute_name(:item_name), excel_width: 35 },
                               ItemReport),
    Datatable::TableColumn.new(:brand, { humanize_name: ItemReport.human_attribute_name(:brand), class_name: 'Ipos::Brand', type: 'model' },
                               ItemReport),
    Datatable::TableColumn.new(:item_type, { humanize_name: ItemReport.human_attribute_name(:item_type), class_name: 'Ipos::ItemType', type: 'model' },
                               ItemReport),
    Datatable::TableColumn.new(:supplier, { humanize_name: ItemReport.human_attribute_name(:supplier), class_name: 'Ipos::Supplier', type: 'model' },
                               ItemReport),
    Datatable::TableColumn.new(:sell_price, { humanize_name: 'Harga Jual', type: 'money' },
                               Discount),
    Datatable::TableColumn.new(:discount, { humanize_name: 'Diskon', type: 'string' },
                               Discount),
    Datatable::TableColumn.new(:sell_price_after_discount, { humanize_name: 'Harga Setelah Diskon', type: 'money' },
                               Discount)
  ]
  def generate_file(reports, discount)
    generator = ExcelGenerator.new
    generator.add_column_definitions(@@column_definitions)
    generator.set_row_data_type_hash!
    generator.add_data(reports)
    filter = {
      'Periode Aktif' => "#{discount.start_time.strftime('%d/%m/%y %H:%M')} - #{discount.end_time.strftime('%d/%m/%y %H:%M')}",
      'Tipe diskon' => discount.calculation_type.to_s,
      'diskon 1' => discount.percentage? ? "#{discount.discount1}%" : money_format(discount.discount1),
      'diskon 2' => "#{discount.discount2}%",
      'diskon 3' => "#{discount.discount3}%",
      'diskon 4' => "#{discount.discount4}%"
    }
    generator.add_metadata(filter)
    generator.generate("laporan-diskon-item-#{discount.code}-#{timestamp}")
  end

  def timestamp
    Time.now.strftime('%y%m%d%H%M%S')
  end
end
