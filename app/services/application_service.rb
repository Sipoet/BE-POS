class ApplicationService
  attr_reader :params, :current_user

  def self.run(controller)
    service = new(controller: controller, current_user: controller.current_user, params: controller.params)
    service.execute
  end

  def initialize(params:, current_user:, controller: nil)
    @params = params
    @controller = controller
    @current_user = current_user
  end

  def execute_service
    raise 'should init on child class'
  end

  def execute
    execute_service
  rescue RecordNotFound => e
    render_not_found_json(record_type: e.record_type, record_id: e.record_id)
  end

  def run_from_controller?
    @controller.present?
  end

  protected

  def target_class
    @target_class ||= self.class.name.split('::').first.constantize
  end

  def render_json(data, options = { status: :ok })
    options[:json] = if data.is_a?(String)
                       data
                     else
                       data.to_json
                     end
    @controller.render options
  end

  def render_not_found_json(record_type: 'data', record_id: '')
    @controller.render json: { message: "#{record_type} #{record_id} tidak ditemukan" }, status: :not_found
  end

  def render_error_record(record)
    render_json({ message: 'Gagal disimpan', errors: record.errors.full_messages }, { status: :conflict })
  end

  def execute_sql(query)
    ActiveRecord::Base.connection.execute(query)
  end

  def superadmin?
    current_user.role_id == Role.superadmin_id
  end

  def permitted_edit_columns(record_class, whitelist_columns)
    table_definition = Datatable::DefinitionExtractor.new(record_class)
    return whitelist_columns if superadmin?

    column_names = ColumnAuthorize.columns_by_role(current_user.role_id, record_class.to_s)
                                  .map do |column_name|
                                    column_definition = table_definition.column_of(column_name)
                                    if column_definition.blank? || !column_definition.can_edit
                                      nil
                                    else
                                      column_definition.name.try(:to_sym)
                                    end
                                  end
    column_names.compact!
    Rails.logger.debug "===EDIT COLUMN=== whitelist_columns #{whitelist_columns} column_names #{column_names}"
    whitelist_columns & column_names
  end

  def permitted_column_names(record_class, whitelist_columns)
    table_definition = Datatable::DefinitionExtractor.new(record_class)
    whitelist_columns = table_definition.column_names if whitelist_columns.blank?
    return whitelist_columns if superadmin?

    column_names = []
    ColumnAuthorize.columns_by_role(current_user.role_id, record_class.to_s)
                   .each do |column_name|
                     column_definition = table_definition.column_of(column_name)
                     next if column_definition.nil?

                     column_names << column_definition.name.to_sym
                     column_names << column_definition.alias_name.to_sym if column_definition.alias_name.present?
    end

    Rails.logger.debug "===#{record_class}===whitelist_columns #{whitelist_columns} column_names #{column_names}"
    whitelist_columns & column_names
  end

  def filter_authorize_fields(record_class:, fields: {})
    if superadmin?
      return nil if fields.values.map(&:empty?).all?

      return fields
    end

    authorized_fields = {}
    table_definition = Datatable::DefinitionExtractor.new(record_class)
    fields.each do |key, values|
      column_definition = table_definition.column_of(key)
      authorized_fields[key] = if column_definition.present?
                                 permitted_column_names(column_definition.relation_class, values)
                               else
                                 permitted_column_names(record_class, values)
                               end
    end
    authorized_fields
  end

  class RecordNotFound < StandardError
    attr_reader :record_id, :record_type

    def initialize(record_id, record_type)
      @record_id = record_id
      @record_type = record_type
      super("#{record_type} #{@record_id} tidak ditemukan")
    end
  end

  class ValidationError < StandardError; end
end
