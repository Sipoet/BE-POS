module DiscountAffectedItem
  extend ActiveSupport::Concern
  # included do

  # end

  def items_based_discount(discount)
    raise 'not record discount' unless discount.is_a?(Discount)

    filter_groups = discount.discount_filters.group_by(&:filter_key)
    items = ItemReport.order(item_code: :asc)
    filter_items = filter_groups['item']
    unless filter_items.nil?
      result = filter_items.each_with_object({ true => [], false => [] }) do |filter_item, obj|
        obj[filter_item.is_exclude] << filter_item.value
      end
      items = items.where(item_code: result[false]) if result[false].present?
      items = items.where.not(item_code: result[true]) if result[true].present?
    end

    filter_items = filter_groups['supplier']
    unless filter_items.nil?
      result = filter_items.each_with_object({ true => [], false => [] }) do |filter_item, obj|
        obj[filter_item.is_exclude] << filter_item.value
      end
      items = items.where(supplier_code: result[false]) if result[false].present?
      items = items.where.not(supplier_code: result[true]) if result[true].present?
    end

    filter_items = filter_groups['brand']
    unless filter_items.nil?
      result = filter_items.each_with_object({ true => [], false => [] }) do |filter_item, obj|
        obj[filter_item.is_exclude] << filter_item.value
      end

      items = items.where(brand_name: result[false]) if result[false].present?
      items = items.where.not(brand_name: result[true]) if result[true].present?
    end
    filter_items = filter_groups['item_type']
    unless filter_items.nil?
      result = filter_items.each_with_object({ true => [], false => [] }) do |filter_item, obj|
        obj[filter_item.is_exclude] << filter_item.value
      end
      items = items.where(item_type_name: result[false]) if result[false].present?
      items = items.where.not(item_type_name: result[true]) if result[true].present?
    end
    filter_items = filter_groups['purchase_date']
    unless filter_items.nil?
      result = filter_items.each_with_object({ true => [], false => [] }) do |filter_item, obj|
        obj[filter_item.is_exclude] << filter_item.value
      end
      if result[false].present?
        daterange = convert_to_daterange(result[false].first)
        purchases = Ipos::Purchase.where(tanggal: daterange)
        purchase_items = Ipos::PurchaseItem.where(purchase: purchases)
        item_codes = purchase_items.pluck(:kodeitem)
        first_date_balance = Ipos::BeginningBalance.minimum(:tanggal)
        if daterange.include?(first_date_balance)
          item_codes += Ipos::BeginningBalance.where(tanggal: daterange).pluck(:kodeitem)
        end
        items = items.where(item_code: item_codes)
      end
      if result[true].present?
        daterange = convert_to_daterange(result[true].first)
        purchases = Ipos::Purchase.where(tanggal: daterange)
        purchase_items = Ipos::PurchaseItem.where.not(purchase: purchases)
        item_codes = purchase_items.pluck(:kodeitem)
        first_date_balance = Ipos::BeginningBalance.minimum(:tanggal)
        unless daterange.include?(first_date_balance)
          item_codes += Ipos::BeginningBalance.where(tanggal: daterange).pluck(:kodeitem)
        end
        items = items.where(item_code: item_codes)
      end
    end
    items
  end

  def convert_to_daterange(range_string)
    start_date, end_date = range_string.split('|').map(&:to_date)
    start_date..end_date
  end
end
