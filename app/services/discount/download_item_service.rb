class Discount::DownloadItemService < ApplicationService
  include ActionView::Helpers::NumberHelper

  def execute_service
    discount = Discount.find_by(id: @params[:id])
    raise ApplicationService::RecordNotFound.new(@params[:id],Discount.name) if discount.nil?
    reports = find_reports(discount)
    file = generate_file(reports,discount)
    @controller.send_file file
  end

  def find_reports(discount)
    query = ItemReport.order(item_code: :asc)
    item_codes = discount.discount_items.where(is_exclude: true).pluck(:item_code)
    if item_codes.present?
      query = query.where.not(item_code: item_codes)
    end
    item_codes = discount.discount_items.where(is_exclude: false).pluck(:item_code)
    if item_codes.present?
      query = query.where(item_code: item_codes)
    end

    item_type_names = discount.discount_item_types.where(is_exclude: true).pluck(:item_type_name)
    if item_type_names.present?
      query = query.where.not(item_type_name: item_type_names)
    end
    item_type_names = discount.discount_item_types.where(is_exclude: false).pluck(:item_type_name)
    if item_type_names.present?
      query = query.where(item_type_name: item_type_names)
    end

    brand_names = discount.discount_brands.where(is_exclude: true).pluck(:brand_name)
    if brand_names.present?
      query = query.where.not(brand_name: brand_names)
    end
    brand_names = discount.discount_brands.where(is_exclude: false).pluck(:brand_name)
    if brand_names.present?
      query = query.where(brand_name: brand_names)
    end

    supplier_codes = discount.discount_suppliers.where(is_exclude: true).pluck(:supplier_code)
    if supplier_codes.present?
      query = query.where.not(supplier_code: supplier_codes)
    end
    supplier_codes = discount.discount_suppliers.where(is_exclude: false).pluck(:supplier_code)
    if supplier_codes.present?
      query = query.where(supplier_code: supplier_codes)
    end

    query.to_a.map do |item_report|
      row = {}
      discount_amount = calculate_discount(discount,item_report.sell_price)
      WHITELIST_COLUMN.each do |key|
        row[key] = item_report[key]
      end
      row[:discount] = discount_format(discount, discount_amount)
      row[:sell_price_after_discount] = item_report.sell_price - discount_amount
      row
    end
  end

  def calculate_discount(discount,sell_price = 0)
    if discount.special_price?
      return sell_price - discount.discount1
    end
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
    return (sell_price - discount_amount) * discount.discount4 / 100
  end

  def discount_format(discount, discount_amount)
    return  "SP #{money_format(discount.discount1)}" if discount.special_price?
    if discount.percentage?
      return [discount.discount1,discount.discount2,discount.discount3,discount.discount4].select{|x|x> 0}
                .map{|percent| "#{percent}%"}
                .join(', ')
    else
      return money_format(discount_amount)
    end
  end

  def money_format(value)
    number_to_currency(value, unit: 'Rp ', separator: ',', delimiter: '.')
  end

  WHITELIST_COLUMN = [:item_code,:brand_name,:item_type_name,:sell_price]

  def generate_file(reports, discount)
    column_definitions = Datatable::DefinitionExtractor.new(ItemReport)
                              .column_definitions
                              .select {|column| WHITELIST_COLUMN.include?(column.name)}

    column_definitions += [
      Datatable::TableColumn.new(:discount, {humanize_name: 'Diskon'}),
      Datatable::TableColumn.new(:sell_price_after_discount, {humanize_name: 'Harga Setelah Diskon',type: 'money'}),
    ]
    generator = ExcelGenerator.new
    generator.add_column_definitions(column_definitions)
    generator.set_row_data_type_hash!
    generator.add_data(reports)
    filter = {
      'Periode Aktif' => "#{discount.start_time.strftime('%d/%m/%y %H:%M')} - #{discount.end_time.strftime('%d/%m/%y %H:%M')}",
      'Tipe diskon' => discount.calculation_type.to_s,
      'diskon 1' => discount.percentage? ? "#{discount.discount1}%": money_format(discount.discount1),
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
