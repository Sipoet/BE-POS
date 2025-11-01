class RefreshActivePromotionJob < ApplicationJob
  sidekiq_options queue: 'low'

  def perform
    check_if_cancelled!
    debug_log 'refresh active promotion start'
    Ipos::Item.where(kodeitem: active_promotion_item_codes)
              .maximum(:tanggal_add)
    items = Ipos::Item.where('dateupd > ? OR tanggal_add >?', 1.hours.ago, 1.hours.ago)
    item_codes = items.pluck(:kodeitem)
    supplier_codes = items.select(:supplier1).distinct
    brand_names = items.select(:merek).distinct
    item_type_names = items.select(:jenis).distinct
    items.group_by { |item| [item.supplier1, item.jenis, item.merek] }
    discounts = discount_based_item(supplier_codes, item_type_names, brand_names, item_codes)

    ActiveRecord::Base.transaction do
      check_active_promotion
      discounts.each do |discount|
        RefreshPromotionJob.new.perform(discount.id)
        check_if_cancelled!
      end
    end
    debug_log 'refresh active promotion done'
  rescue JobCancelled
    debug_log "job #{jid} cancelled safely"
  end

  private

  def check_active_promotion
    today = Time.now
    Ipos::Promotion.where(tglsampai: ...today)
                   .update_all(stsact: false)
  end

  def active_promotion_item_codes
    ids = Ipos::Promotion.active_today
                         .pluck(:iddiskon)
    Ipos::ItemPromotion.where(iddiskon: ids)
                       .pluck(:kodeitem)
  end

  def discount_based_item(supplier_codes, item_type_names, brand_names, item_codes)
    Discount.active_today
            .where('item_code IN (?) OR item_type_name IN (?) OR brand_name IN (?) OR supplier_code IN (?)', item_codes, item_type_names, brand_names, supplier_codes)
            .to_a
  end
end
