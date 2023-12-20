class ServiceGenerator < Rails::Generators::NamedBase
  class_option :service, type: :string
  def create_initializer_file
    service_name = options["service"]
    raise 'service must be filled' if service_name.blank?
    model_name = file_name.singularize
    create_file "app/services/#{model_name.singularize}/#{service_name}_service.rb", <<~END
    class #{model_name.classify}::#{service_name.classify}Service < BaseService

      def execute_service
        # insert code here
      end

    end

    END
  end
end
