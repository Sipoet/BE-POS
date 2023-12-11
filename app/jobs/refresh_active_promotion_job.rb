class RefreshActivePromotionJob < ApplicationJob
  sidekiq_options queue: 'default'

  def perform
    debug_log 'refresh active promotion start'
    last_updated = Item.where(kodeitem: active_promotion_item_codes)
                .maximum(:tanggal_add)
    items = Item.where('tanggal_add > ?', last_updated)
    group_discounts = {}
    group_discounts.default = []
    items.each do |item,obj|
      discount = discount_based_item(item)
      next if discount.nil?
      group_discounts[discount] << item
    end

    ActiveRecord::Base.transaction do
      group_discounts.each {|discount,items| generate_ipos_promotion(discount, items)}
    end
    debug_log 'refresh active promotion done'
  end

  private

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
    ids = Promotion.active_today
                   .pluck(:iddiskon)
    ItemPromotion.where(iddiskon: ids)
                 .pluck(:kodeitem)
  end

  def discount_based_item(item)
    discounts = Discount.active_today
                        .where(item_code: [item.kodeitem,nil],
                              supplier_code: [item.supplier1,nil],
                              item_type: [item.jenis,nil],
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
    ItemPromotion.insert_all(item_p_docs)
  end

  def create_promotion!(promo_name:, start_time:, end_time:)
    debug_log "create promotion #{promo_name}"
    promotion = Promotion.find_or_initialize_by(iddiskon: promo_name)
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
