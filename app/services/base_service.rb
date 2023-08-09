class BaseService
  def self.run(controller)
    service = self.new(controller)
    service.execute_service
  end


  def def initialize(controller)
    @params = controller.params
    @controller = controller
  end


  def execute_sql(query)
    ActiveRecord::Base.connection.execute(query)
  end
end