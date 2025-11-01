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
  ALL_COLUMN = :all_column
  def permitted_column_names(record_class)
    return ALL_COLUMN if current_user.role.name == Role::SUPERADMIN

    table_definitions = Datatable::DefinitionExtractor.new(record_class)
    ColumnAuthorize.where(role_id: current_user.role_id, table: record_class.name.underscore)
                   .pluck(:column)
                   .map { |column_name| table_definitions.column_of(column_name).try(:filter_key) }
                   .compact
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
