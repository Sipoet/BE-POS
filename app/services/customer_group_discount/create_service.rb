class CustomerGroupDiscount::CreateService < ApplicationService

  def execute_service
    customer_group_discount = CustomerGroupDiscount.new
    if record_save?(customer_group_discount)
      options = {
        fields: @fields,
        include: ['customer_group'],
        params:{include:['customer_group']}
      }
      render_json(CustomerGroupDiscountSerializer.new(customer_group_discount, options),{status: :created})
    else
      render_error_record(customer_group_discount)
    end
  end

  def record_save?(customer_group_discount)
    ApplicationRecord.transaction do
      update_attribute(customer_group_discount)
      customer_group_discount.save!
    end
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  def update_attribute(customer_group_discount)
    allowed_columns = CustomerGroupDiscount::TABLE_HEADER.map(&:name)
    @fields = {customer_group_discount: allowed_columns}
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(allowed_columns)
    customer_group_discount.attributes = permitted_params
  end
end
