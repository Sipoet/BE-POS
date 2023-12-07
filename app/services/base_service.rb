class BaseService
  def self.run(controller)
    service = self.new(controller)
    service.execute_service
  end

  def initialize(controller)
    @params = controller.params
    @controller = controller
  end

  def execute_service
    raise 'should init on child class'
  end

  def render_json(data, options = {status: 200})
    if data.is_a?(String)
      options[:json] = data
    else
      options[:json] = data.to_json
    end
    @controller.render options
  end

  protected

  def execute_sql(query)
    ActiveRecord::Base.connection.execute(query)
  end

end
