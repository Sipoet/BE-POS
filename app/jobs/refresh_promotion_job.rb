class RefreshPromotionJob < ApplicationJob
  sidekiq_options queue: 'default', retry: 1

  def perform(id)
    @blacklist_item_codes = []
    discount = Discount.find(id)
    ActiveRecord::Base.transaction do
      delete_old_promotion(discount)
      items = items_based_discount(discount)
      check_conflict_promotion(discount, items)
      items.reject!{|item| @blacklist_item_codes.include?(item.kodeitem)}
      generate_ipos_promotion(discount, items)
    end
  end

  private

  def delete_old_promotion(discount)
    promotions = Promotion.where('iddiskon ilike ?', "%_#{discount.code}%")
    if promotions.exists?
      ItemPromotion.delete_by_iddiskon(promotions.pluck(:iddiskon))
      promotions.delete_all
    else
      raise "#{discount.code} not exists"
    end
  end

  def items_based_discount(discount)
    items = Item.order(kodeitem: :asc)
    {
      kodeitem: discount.item_code,
      supplier1: discount.supplier_code,
      jenis: discount.item_type,
      merek: discount.brand_name
    }.each do |key, value|
      items = items.where(key => value) if value.present?
    end
    items.to_a
  end

  def check_conflict_promotion(discount, items)
    iddiskon = Promotion.active_today.pluck(:iddiskon)
    item_promotions = ItemPromotion.where(kodeitem: items.pluck(:kodeitem), iddiskon: iddiskon)
    if item_promotions.present?
      item_promotions.each do |item_promotion|
        if item_promotion.diskon1 <= discount.discount1
          @blacklist_item_codes << item_promotion.kodeitem
        else
          item_promotion.delete
        end
        debug_log "conflict diskon #{item_promotion.iddiskon} with item code #{item_promotion.kodeitem}"
      end

    end
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
    ids = Promotion.active_today
                   .pluck(:iddiskon)
    ItemPromotion.where(iddiskon: ids)
                 .pluck(:kodeitem)
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
