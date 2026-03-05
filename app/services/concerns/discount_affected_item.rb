module DiscountAffectedItem
  extend ActiveSupport::Concern
  # included do

  # end

  def items_based_discount(discount)
    raise 'not record discount' unless discount.is_a?(Discount)

    filter_groups = discount.discount_filters.group_by(&:filter_key)
    item_reports = ItemReport.order(item_code: :asc)
    filter_items = filter_groups['item']
    unless filter_items.nil?
      result = filter_items.each_with_object({ true => [], false => [] }) do |filter_item, obj|
        obj[filter_item.is_exclude] << filter_item.value
      end
      item_reports = item_reports.where(item_code: result[false]) if result[false].present?
      item_reports = item_reports.where.not(item_code: result[true]) if result[true].present?
    end

    filter_items = filter_groups['supplier']
    unless filter_items.nil?
      result = filter_items.each_with_object({ true => [], false => [] }) do |filter_item, obj|
        obj[filter_item.is_exclude] << filter_item.value
      end
      item_reports = item_reports.where(supplier_code: result[false]) if result[false].present?
      item_reports = item_reports.where.not(supplier_code: result[true]) if result[true].present?
    end

    filter_items = filter_groups['brand']
    unless filter_items.nil?
      result = filter_items.each_with_object({ true => [], false => [] }) do |filter_item, obj|
        obj[filter_item.is_exclude] << filter_item.value
      end

      item_reports = item_reports.where(brand_name: result[false]) if result[false].present?
      item_reports = item_reports.where.not(brand_name: result[true]) if result[true].present?
    end
    filter_items = filter_groups['item_type']
    unless filter_items.nil?
      result = filter_items.each_with_object({ true => [], false => [] }) do |filter_item, obj|
        obj[filter_item.is_exclude] << filter_item.value
      end
      item_reports = item_reports.where(item_type_name: result[false]) if result[false].present?
      item_reports = item_reports.where.not(item_type_name: result[true]) if result[true].present?
    end
    filter_items = filter_groups['purchase_date']
    unless filter_items.nil?
      result = filter_items.each_with_object({ true => [], false => [] }) do |filter_item, obj|
        obj[filter_item.is_exclude] << filter_item.value
      end
      if result[false].present?
        daterange = convert_to_daterange(result[false].first)
        purchases = Ipos::ItemInHeader.where(tanggal: daterange, tipe: %w[BL KI IM])
        purchase_items = Ipos::PurchaseItem.where(purchase: purchases)
        first_date_balance = Ipos::BeginningBalance.minimum(:tanggal).to_datetime
        if daterange.include?(first_date_balance)
          beginning_balances = Ipos::BeginningBalance.where(tanggal: daterange)
          item_reports = item_reports.and(ItemReport.where(purchase_items: purchase_items).or(ItemReport.where(beginning_balances: beginning_balances)))
        else
          item_reports = item_reports.where(purchase_items: purchase_items)
        end
      end
      if result[true].present?
        daterange = convert_to_daterange(result[true].first)
        purchases = Ipos::ItemInHeader.where(tanggal: daterange, tipe: %w[BL KI IM])
        purchase_items = Ipos::PurchaseItem.where.not(purchase: purchases)

        first_date_balance = Ipos::BeginningBalance.minimum(:tanggal).to_datetime
        if daterange.include?(first_date_balance)
          item_reports = item_reports.where(purchase_items: purchase_items)
        else
          beginning_balances = Ipos::BeginningBalance.where.not(tanggal: daterange)
          item_reports = item_reports.and(ItemReport.where(purchase_items: purchase_items).or(ItemReport.where(beginning_balances: beginning_balances)))
        end
      end
    end
    Rails.logger.debug "=====sql: #{item_reports.to_sql}"
    item_reports
  end

  def convert_to_daterange(range_string)
    start_date, end_date = range_string.split('|').map(&:to_date)
    (start_date.to_datetime.utc.beginning_of_day)..(end_date.to_datetime.utc.end_of_day)
  end
end
