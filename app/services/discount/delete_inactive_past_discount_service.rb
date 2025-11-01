class Discount::DeleteInactivePastDiscountService < ApplicationService
  def execute_service
    Discount.transaction do
      Discount.where(end_time: ...(DateTime.now))
              .each { |discount| delete_discount(discount) }
    end
    render_json({ message: 'Diskon lama sukses dihapus' })
  end

  def delete_discount(discount)
    discount.delete_promotion
    discount.destroy!
  end
end
