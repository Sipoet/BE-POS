class CustomerGroupDiscount::DestroyService < ApplicationService

  def execute_service
    customer_group_discount = CustomerGroupDiscount.find( params[:id])
    raise RecordNotFound.new(params[:id],CustomerGroupDiscount.model_name.human) if customer_group_discount.nil?
    if customer_group_discount.destroy
      render_json({message: "#{customer_group_discount.id} sukses dihapus"})
    else
      render_error_record(customer_group_discount)
    end
  end
end
