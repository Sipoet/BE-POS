class RefreshPromotionJob < ApplicationJob
  sidekiq_options queue: 'default', retry: 2

  def perform(id)
    dont_run_in_parallel! do
      check_if_cancelled!
      @blacklist_item_codes = []
      discount = Discount.find(id)
      ActiveRecord::Base.transaction do
        delete_old_promotion(discount)
        return if DateTime.now < discount.start_time
        items = items_based_discount(discount)
        check_conflict_promotion(discount, items)
        check_if_cancelled!
        items.reject!{|item| @blacklist_item_codes.include?(item.kodeitem)}
        generate_ipos_promotion(discount, items)
        check_if_cancelled!
      end
    end
  rescue JobCancelled => e
    debug_log "job #{jid} cancelled safely"
  end

  private

  def delete_old_promotion(discount)
    discount.delete_promotion
  end

  def items_based_discount(discount)
    items = Ipos::Item.order(kodeitem: :asc)
    {
      kodeitem: discount.discount_items.where(is_exclude: false).pluck(:item_code),
      supplier1: discount.discount_suppliers.where(is_exclude: false).pluck(:supplier_code),
      jenis: discount.discount_item_types.where(is_exclude: false).pluck(:item_type_name),
      merek: discount.discount_brands.where(is_exclude: false).pluck(:brand_name)
    }.each do |key, value|
      items = items.where(key => value) if value.present?
    end
    {
      supplier1: discount.discount_suppliers.where(is_exclude: true).pluck(:supplier_code),
      jenis: discount.discount_item_types.where(is_exclude: true).pluck(:item_type_name),
      merek: discount.discount_brands.where(is_exclude: true).pluck(:brand_name)
    }.each do |key, value|
      items = items.where.not(key => value) if value.present?
    end
    items.to_a
  end

  def check_conflict_promotion(discount, items)
    iddiskon = Ipos::Promotion.active_range(discount.start_time, discount.end_time).pluck(:iddiskon)
    item_promotions = Ipos::ItemPromotion.where(kodeitem: items.pluck(:kodeitem), iddiskon: iddiskon)
    item_promotions.each do |item_promotion|
      ip_discount = item_promotion.discount
      if ip_discount.day_of_week? && discount.day_of_week? && ![ip_discount.week1 == discount.week1,
        ip_discount.week2 == discount.week2,
        ip_discount.week3 == discount.week3,
        ip_discount.week4 == discount.week4,
        ip_discount.week5 == discount.week5,
        ip_discount.week6 == discount.week6,
        ip_discount.week7 == discount.week7
      ].any?
        next
      end
      promotion_weight = discount.try(:weight) || 0
      if promotion_weight >= discount.weight
        @blacklist_item_codes << item_promotion.kodeitem
      else
        item_promotion.delete
      end
      debug_log "conflict diskon #{item_promotion.iddiskon} with item code #{item_promotion.kodeitem}"

    end
  end

  def generate_ipos_promotion(discount, items)
    items.each_slice(200).with_index(1) do |paginated_items, page|
      promo_name = "#{page}_#{discount.code}"
      promotion = create_promotion!(promo_name: promo_name,
                                    discount: discount)
      create_item_promotions(items: paginated_items,
                            promotion: promotion,
                            discount: discount)
    end
  end

  def active_promotion_item_codes
    ids = Ipos::Promotion.active_today
                         .pluck(:iddiskon)
    Ipos::ItemPromotion.where(iddiskon: ids)
                       .pluck(:kodeitem)
  end

  def create_item_promotions(items:[],promotion:,discount:)
    item_p_docs = items.map do |item|
      debug_log "item #{item.kodeitem} diskon #{discount}"
        {
          iddiskon: promotion.iddiskon,
          kodeitem: item.kodeitem,
          satuan: item.satuan,
          opsidiskon: discount.percentage? ? 1 : 2,
          diskon1: discount.discount1,
          diskon2: discount.discount2,
          diskon3: discount.discount3,
          diskon4: discount.discount4,
        }
    end
    Ipos::ItemPromotion.insert_all(item_p_docs)
  end

  def create_promotion!(promo_name:, discount:)
    debug_log "create promotion #{promo_name}"
    promotion = Ipos::Promotion.find_or_initialize_by(iddiskon: promo_name)
    promotion.tgldari = discount.start_time.strftime('%Y-%m-%d %H:%M:%Sz')
    promotion.tglsampai = discount.end_time.strftime('%Y-%m-%d %H:%M:%Sz')
    promotion.stsact = if discount.day_of_week?
      day_of_week = DateTime.now.cwday
      discount.try("week#{day_of_week}")
    else
      DateTime.now.between?(discount.start_time,discount.end_time)
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
    promotion.tipeper = (Discount.discount_types[discount.discount_type] + 1).to_s
    Sidekiq.logger.info "======= #{promotion.tipeper}"
    promotion.save!
    promotion
  end
end
