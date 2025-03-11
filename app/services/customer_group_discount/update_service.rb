class CustomerGroupDiscount::UpdateService < ApplicationService

  def execute_service
    customer_group_discount = CustomerGroupDiscount.find(params[:id])
    raise RecordNotFound.new(params[:id],CustomerGroupDiscount.model_name.human) if customer_group_discount.nil?
    if record_save?(customer_group_discount)
      options = {
        fields: @fields,
        include: ['customer_group'],
        params:{include:['customer_group']}
      }
      ToggleCustomerGroupDiscountJob.perform_async
      render_json(CustomerGroupDiscountSerializer.new(customer_group_discount,options))
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
    table_definitions = Datatable::DefinitionExtractor.new(CustomerGroupDiscount)
    allowed_columns = table_definitions.column_names
    @fields = {customer_group_discount: allowed_columns}
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(allowed_columns)
    customer_group_discount.attributes = permitted_params
  end
end
