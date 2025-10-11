class Product::DestroyService < ApplicationService

  def execute_service
    product = Product.find( params[:id])
    raise RecordNotFound.new(params[:id],Product.model_name.human) if product.nil?
    if product.destroy
      render_json({message: "#{product.id} sukses dihapus"})
    else
      render_error_record(product)
    end
  end
end
