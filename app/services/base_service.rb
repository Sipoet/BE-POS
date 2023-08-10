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

  protected

  def execute_sql(query)
    ActiveRecord::Base.connection.execute(query)
  end

  def paginate_query(query:, page:, per:)
    offset = (page - 1) * per
    query + "\n offset #{offset} limit #{per}"
  end
end