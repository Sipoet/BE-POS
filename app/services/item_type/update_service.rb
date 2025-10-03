class ItemType::UpdateService < ApplicationService

  def execute_service
    item_type = Ipos::ItemType.find(params[:id])
    raise RecordNotFound.new(params[:id],Ipos::ItemType.model_name.human) if item_type.nil?
    if record_save?(item_type)
      render_json(Ipos::ItemTypeSerializer.new(item_type,{fields: @fields}))
    else
      render_error_record(item_type)
    end
  end

  def record_save?(item_type)
    ApplicationRecord.transaction do
      update_attribute(item_type)
      item_type.save!
    end
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  def update_attribute(item_type)
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::ItemType)
    @fields = {item_type: @table_definitions.allowed_columns}
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(@table_definitions.allowed_edit_columns)
    item_type.attributes = permitted_params
  end
end
