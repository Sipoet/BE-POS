class RefreshActivePromotionJob < ApplicationJob
  sidekiq_options queue: 'low'

  def perform
    check_if_cancelled!
    debug_log 'refresh active promotion start'
    last_updated = Ipos::Item.where(kodeitem: active_promotion_item_codes)
                .maximum(:tanggal_add)
    items = Ipos::Item.where('dateupd > ? or tanggal_add >?', 1.hours.ago, 1.hours.ago)
    group_discounts = {}
    group_discounts.default = []
    items.each do |item|
      discount = discount_based_item(item)
      next if discount.nil?
      group_discounts[discount] += [item]
    end

    ActiveRecord::Base.transaction do
      check_active_promotion
      group_discounts.each do |discount,items|
        generate_ipos_promotion(discount, items)
        check_if_cancelled!
      end
    end
    debug_log 'refresh active promotion done'
  rescue JobCancelled => e
    debug_log "job #{jid} cancelled safely"
  end

  private

  def check_active_promotion
    Ipos::Promotion.where(tglsampai: ...Time.now)
             .update_all(stsact: false)
    today = Time.now
    Ipos::Promotion.within_range(today,today).update_all(stsact: true)

  end

  def generate_ipos_promotion(discount, items)
    items.each_slice(200).with_index(1) do |paginated_items, page|
      promo_name = "#{page}_#{discount.code}"
      promotion = create_promotion!(promo_name: promo_name,
                                    start_time: discount.start_time,
                                    end_time: discount.end_time)
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

  def discount_based_item(item)
    discounts = Discount.active_today
                        .where(item_code: [item.kodeitem,nil],
                              supplier_code: [item.supplier1,nil],
                              item_type_name: [item.jenis,nil],
                              brand_name: [item.merek, nil])
                        .to_a
    if discounts.length == 1
      return discounts[0]
    elsif discounts.empty?
      return nil
    else
      priority_discount = discounts.find{|discount|discount.item_code.present?}
      return priority_discount if priority_discount.present?
      return discounts[0]
    end
  end

  def create_item_promotions(items:[],promotion:,discount:)
    item_p_docs = items.map do |item|
      debug_log "item #{item.kodeitem} diskon #{discount}"
        {
          iddiskon: promotion.iddiskon,
          kodeitem: item.kodeitem,
          satuan: item.satuan,
          opsidiskon: 1,
          diskon1: discount.discount1,
          diskon2: discount.discount2,
          diskon3: discount.discount3,
          diskon4: discount.discount4,
        }
    end
    Ipos::ItemPromotion.insert_all(item_p_docs)
  end

  def create_promotion!(promo_name:, start_time:, end_time:)
    debug_log "create promotion #{promo_name}"
    promotion = Ipos::Promotion.find_or_initialize_by(iddiskon: promo_name)
    promotion.tgldari = start_time.strftime('%Y-%m-%d %H:%M:%Sz')
    promotion.tglsampai = end_time.strftime('%Y-%m-%d %H:%M:%Sz')
    promotion.stsact = DateTime.now.between?(start_time,end_time)
    promotion.jamdari = promotion.tgldari
    promotion.jamsampai = promotion.tglsampai
    promotion.prioritas = 1
    promotion.pot1 = 0
    promotion.pot2 = 0
    promotion.pot3 = 0
    promotion.pot4 = 0
    promotion.tipeper = '1'
    promotion.save!
    promotion
  end
end
