class Discount::ItemDiscountFinder

  def find(item_code:, transaction_date:)
    actived_discount_rules = active_discount_rules(transaction_date)
    discount_rule_ids = DiscountGroupItem.where(item_code: item_code,
                                        discount_rule: actived_discount_rules)
                                  .pluck(:discount_rule_id)
    DiscountRule.find(discount_rule_ids)
  end

  private

  def active_discount_rules(transaction_date)
    DiscountRule.where(ApplicationRecord.sanitize_sql_array(["? BETWEEN start_time AND end_time",transaction_date]))
  end

end
