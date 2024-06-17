class ToggleCustomerGroupDiscountJob < ApplicationJob
  sidekiq_options queue: 'default'

  def perform
    ApplicationRecord.transaction do
      Ipos::CustomerGroup.all
                        .update_all(potongan: 0)
      CustomerGroupDiscount.active_date(today)
                           .group_by(&:customer_group)
                          .each do |customer_group ,customer_group_discounts|
        discount_percentage = discount_percentage_of(customer_group_discounts)
        Sidekiq.logger.debug "#{customer_group.kgrup} discount #{discount_percentage}%"
        customer_group.update!(potongan: discount_percentage)
      end
    end
  end

  private

  def discount_percentage_of(customer_group_discounts)
    level = 0
    discount_percentage = 0
    customer_group_discounts.each do |customer_group_discount|
      if level <= customer_group_discount.level && valid?(customer_group_discount)
        level = customer_group_discount.level
        discount_percentage = customer_group_discount.discount_percentage
      end
    end
    discount_percentage
  end
  def valid?(customer_group_discount)
    period_type = customer_group_discount.period_type
    self.send("#{period_type}_valid?",customer_group_discount)
  end

  def active_period_valid?(customer_group_discount)
    true
  end

  def day_of_month_valid?(customer_group_discount)
    if today == today.end_of_month && (customer_group_discount.variable1 == -1 || customer_group_discount.variable2 == -1)
      return true
    end
    today.day.between?(customer_group_discount.variable1,customer_group_discount.variable2)
  end

  def day_of_week_valid?(customer_group_discount)
    [customer_group_discount.variable1,
    customer_group_discount.variable2,
    customer_group_discount.variable3,
    customer_group_discount.variable4,
    customer_group_discount.variable5,
    customer_group_discount.variable6,
    customer_group_discount.variable7].compact.include?(today.cwday)
  end

  def week_of_month_valid?(customer_group_discount)
    week_nums = [customer_group_discount.variable1,
    customer_group_discount.variable2,
    customer_group_discount.variable3,
    customer_group_discount.variable4,
    customer_group_discount.variable5,
    customer_group_discount.variable6,
    customer_group_discount.variable7].compact

    if today.next_week.month > today.month && week_nums.include?(-1)
      return true
    end
    week_of_month = today.cweek - today.beginning_of_month.cweek + 1
    week_nums.include?(week_of_month)
  end

  def today
    Date.today
  end
end
