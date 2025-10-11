class Product::UpdateService < ApplicationService

  def execute_service
    product = Product.find(params[:id])
    raise RecordNotFound.new(params[:id],Product.model_name.human) if product.nil?
    if record_save?(product)
      render_json(ProductSerializer.new(product,{fields: @fields}))
    else
      render_error_record(product)
    end
  end

  def record_save?(product)
    ApplicationRecord.transaction do
      update_attribute(product)
      product.save!
    end
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  def update_attribute(product)
    @table_definitions = Datatable::DefinitionExtractor.new(Product)
    @fields = {product: @table_definitions.allowed_columns}
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(@table_definitions.allowed_edit_columns)
    product.attributes = permitted_params
  end
end
