class Item::UpdateService < ApplicationService
  def execute_service
    item = Ipos::Item.find(params[:code])
    raise RecordNotFound.new(params[:code], Ipos::Item.model_name.human) if item.nil?

    if record_save?(item)
      render_json(Ipos::ItemSerializer.new(item, { fields: @fields, include: %w[supplier item_type brand] }))
    else
      render_error_record(item)
    end
  end

  def record_save?(item)
    ApplicationRecord.transaction do
      update_attribute!(item)
    end
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def update_attribute!(item)
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::Item)
    @fields = { item: @table_definition.column_names }
    permitted_columns = permitted_edit_columns(Ipos::Item,
                                               %i[name description cogs sell_price supplier_code item_type_name
                                                  brand_name])
    @fields[:item] << 'supplier' if permitted_columns.include?(:supplier_code)
    @fields[:item] << 'brand' if permitted_columns.include?(:brand_name)
    @fields[:item] << 'item_type' if permitted_columns.include?(:item_type_name)
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(*permitted_columns)
    item.update!(permitted_params)
  end
end
