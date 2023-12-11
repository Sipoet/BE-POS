class BaseService

  def self.run(controller)
    service = self.new(controller)
    service.execute
  end

  def initialize(controller = nil)
    @params = controller.try(:params)
    @controller = controller
  end

  def execute_service
    raise 'should init on child class'
  end

  def execute
    begin
      execute_service
    rescue RecordNotFound => e
      render_not_found_json(record_type:e.record_type, record_id: e.record_id)
    end
  end

  def run_from_controller?
    @controller.present?
  end

  protected

  def render_json(data, options = {status: :ok})
    if data.is_a?(String)
      options[:json] = data
    else
      options[:json] = data.to_json
    end
    @controller.render options
  end

  def render_not_found_json(record_type: 'data', record_id: '')
    @controller.render json: {message: "#{record_type} #{record_id} tidak ditemukan"}, status: :not_found
  end

  def execute_sql(query)
    ActiveRecord::Base.connection.execute(query)
  end

  class RecordNotFound < StandardError
    attr_reader :record_id, :record_type
    def initialize(record_id, record_type)
      @record_id = record_id
      @record_type = record_type
      super
    end
  end
end
