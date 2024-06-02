class ToggleCustomerGroupDiscountJob < ApplicationJob
  sidekiq_options queue: 'low'

  def perform
    start_day_per_month = Setting.get('cust_group_discount_start_day_per_month') || 1
    end_day_per_month = Setting.get('cust_group_discount_end_day_per_month') || 5
    discount = 0
    if Date.today.day.between?(start_day_per_month,end_day_per_month)
      discount = Setting.get('cust_group_discount_percentage') || 0
    end
    customer_group_codes = Setting.get('affected_cust_group_code') || []
    Ipos::CustomerGroup.where(kgrup: customer_group_codes)
                       .update_all(potongan: discount)

  end
end
