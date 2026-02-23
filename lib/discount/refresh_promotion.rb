class Discount::RefreshPromotion
  include DiscountAffectedItem
  IPOS_MAX_ITEM_PER_PROMOTION = 200

  attr_reader :discount

  def initialize(discount)
    raise 'not a discount' unless discount.is_a?(Discount)

    @discount = discount
  end

  def refresh!
    @blacklist_item_codes = []
    ActiveRecord::Base.transaction do
      delete_old_promotion
      return if DateTime.now < discount.start_time

      item_reports = items_based_discount(discount)
      items = Ipos::Item.where(code: item_reports.pluck(:item_code))
      check_conflict_promotion(items)
      items = items.where.not(kodeitem: @blacklist_item_codes)
      generate_ipos_promotion(items)
    end
  end

  private

  def delete_old_promotion
    discount.delete_promotion
  end

  def check_conflict_promotion(items)
    iddiskon = Ipos::Promotion.active_range(discount.start_time, discount.end_time).pluck(:iddiskon)
    item_promotions = Ipos::ItemPromotion.where(item: items, iddiskon: iddiskon).includes(:promotion,
                                                                                          promotion: [:discount])
    item_promotions.each do |item_promotion|
      ip_discount = item_promotion.promotion.try(:discount)
      if ip_discount.try(:day_of_week?) && discount.day_of_week? && ![ip_discount.week1 == discount.week1,
                                                                      ip_discount.week2 == discount.week2,
                                                                      ip_discount.week3 == discount.week3,
                                                                      ip_discount.week4 == discount.week4,
                                                                      ip_discount.week5 == discount.week5,
                                                                      ip_discount.week6 == discount.week6,
                                                                      ip_discount.week7 == discount.week7].any?
        next
      end

      promotion_weight = ip_discount.try(:weight) || 0
      if promotion_weight >= discount.weight
        @blacklist_item_codes << item_promotion.kodeitem
      else
        item_promotion.delete
      end
      debug_log "conflict diskon #{item_promotion.iddiskon} with item code #{item_promotion.kodeitem}"
    end
  end

  def generate_ipos_promotion(items)
    item_measurement_quantities = Ipos::ItemMeasurementQuantity.where(item: items)
                                                               .where.not(kodebarcode: nil)
                                                               .includes(:item)
    item_measurement_quantities.each_slice(IPOS_MAX_ITEM_PER_PROMOTION - 1).with_index(1) do |paginated_items, page|
      promo_name = "#{page}_#{discount.code}"
      promotion = create_promotion!(promo_name)
      create_item_promotions(uom_items: paginated_items,
                             promotion: promotion)
    end
  end

  def active_promotion_item_codes
    ids = Ipos::Promotion.active_today
                         .pluck(:iddiskon)
    Ipos::ItemPromotion.where(iddiskon: ids)
                       .pluck(:kodeitem)
  end

  def create_item_promotions(promotion:, uom_items: [])
    item_p_docs = uom_items.map do |uom_item|
      item = uom_item.item
      discount1 = if discount.special_price?
                    item.hargajual1 - discount.discount1
                  else
                    discount.discount1
                  end
      debug_log "item #{item.kodeitem} diskon #{discount.code}"
      {
        iddiskon: promotion.iddiskon,
        kodeitem: item.kodeitem,
        satuan: uom_item.satuan,
        opsidiskon: discount.percentage? ? 1 : 2,
        diskon1: discount1,
        diskon2: discount.discount2,
        diskon3: discount.discount3,
        diskon4: discount.discount4,
        kgruppel: discount.customer_group_code
      }
    end
    Ipos::ItemPromotion.insert_all(item_p_docs)
  end

  def create_promotion!(promo_name)
    debug_log "create promotion #{promo_name}"
    promotion = Ipos::Promotion.find_or_initialize_by(iddiskon: promo_name)
    promotion.tgldari = discount.start_time.strftime('%Y-%m-%d %H:%M:%Sz')
    promotion.tglsampai = discount.end_time.strftime('%Y-%m-%d %H:%M:%Sz')
    promotion.stsact = if discount.day_of_week?
                         day_of_week = DateTime.now.cwday
                         discount.try("week#{day_of_week}")
                       else
                         DateTime.now.between?(discount.start_time, discount.end_time)
                       end
    promotion.jamdari = promotion.tgldari
    promotion.jamsampai = promotion.tglsampai
    promotion.w1 = discount.week1
    promotion.w2 = discount.week2
    promotion.w3 = discount.week3
    promotion.w4 = discount.week4
    promotion.w5 = discount.week5
    promotion.w6 = discount.week6
    promotion.w7 = discount.week7
    promotion.prioritas = 1
    promotion.pot1 = 0
    promotion.pot2 = 0
    promotion.pot3 = 0
    promotion.pot4 = 0
    promotion.discount = discount
    promotion.tipeper = (Discount.discount_types[discount.discount_type] + 1).to_s
    promotion.save!
    promotion
  end

  def debug_log(text)
    Rails.logger.debug text
  end
end
