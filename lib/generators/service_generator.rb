class ServiceGenerator < Rails::Generators::NamedBase

  def create_initializer_file
    raise 'service must be filled' if args.blank?
    model_name = file_name.singularize
    args.each{|service_name| create_file_service(model_name, service_name)}
  end

  private

  def create_file_service(model_name, service_name)
    create_file "app/services/#{model_name}/#{service_name}_service.rb", <<~END
    class #{model_name.classify}::#{service_name.classify}Service < BaseService

      def execute_service
        # insert code here
      end

    end

    END
  end
end
