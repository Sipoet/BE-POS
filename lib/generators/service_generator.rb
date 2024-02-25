class ServiceGenerator < Rails::Generators::NamedBase

  def create_initializer_file
    raise 'service must be filled' if args.blank?
    model_name = file_name.underscore.singularize
    args.each{|service_name| create_file_service(model_name, service_name)}
  end

  private

  def create_file_service(model_name, service_name)
    case service_name
    when 'index'
      index_template(model_name)
    when 'show'
      show_template(model_name)
    when 'create'
      create_template(model_name)
    when 'update'
      update_template(model_name)
    when 'destroy'
      destroy_template(model_name)
    else
      default_template(model_name,service_name)
    end
  end

  def default_template(model_name, service_name)
    create_file "app/services/#{model_name}/#{service_name.singularize}_service.rb", <<~END
    class #{model_name.classify}::#{service_name.classify}Service < ApplicationService

      def execute_service
        # insert code here
      end

    end
    END
  end

  def index_template(model_name)
    plural_name = model_name.pluralize
    klass_name = model_name.classify
    create_file "app/services/#{model_name}/index_service.rb", <<~END
    class #{model_name.classify}::IndexService < ApplicationService

      include JsonApiDeserializer
      def execute_service
        extract_params
        @#{plural_name} = find_#{plural_name}
        options = {
          meta: meta,
          field: @field,
          params:{include: @included},
          include: @included
        }
        render_json(#{klass_name}Serializer.new(@#{plural_name},options))
      end

      def meta
        {
          page: @page,
          limit: @limit,
          total_pages: @#{plural_name}.total_pages,
        }
      end

      def extract_params
        allowed_columns = #{klass_name}::TABLE_HEADER.map(&:name)
        allowed_fields = [:#{model_name}]
        result = dezerialize_table_params(params,
          allowed_fields: allowed_fields,
          allowed_columns: allowed_columns)
        @page = result.page || 1
        @limit = result.limit || 20
        @search_text = result.search_text
        @sort = result.sort
        @included = result.included
        @filters = result.filters
        @field = result.field
      end

      def find_#{plural_name}
        #{plural_name} = #{klass_name}.all.includes(@included)
          .page(@page)
          .per(@limit)
        if @search_text.present?
          #{plural_name} = #{plural_name}.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
        end
        @filters.each do |filter|
          #{plural_name} = #{plural_name}.where(filter.to_query)
        end
        if @sort.present?
          #{plural_name} = #{plural_name}.order(@sort)
        else
          #{plural_name} = #{plural_name}.order(id: :asc)
        end
        #{plural_name}
      end

    end
    END
  end

  def show_template(model_name)
    plural_name = model_name.pluralize
    klass_name = model_name.classify
    create_file "app/services/#{model_name}/show_service.rb", <<~END
    class #{model_name.classify}::ShowService < ApplicationService

      include JsonApiDeserializer
      def execute_service
        extract_params
        #{model_name} = #{klass_name}.find(params[:id])
        raise RecordNotFound.new(params[:id],#{klass_name}.model_name.human) if #{model_name}.nil?
        options = {
          field: @field,
          params:{include: @included},
          include: @included
        }
        render_json(#{klass_name}Serializer.new(#{model_name},options))
      end

      def extract_params
        allowed_columns = #{klass_name}::TABLE_HEADER.map(&:name)
        allowed_fields = [:#{model_name}]
        result = dezerialize_table_params(params,
          allowed_fields: allowed_fields,
          allowed_columns: allowed_columns)
        @included = result.included
        @field = result.field
      end

    end
    END
  end

  def create_template(model_name)
    plural_name = model_name.pluralize
    klass_name = model_name.classify
    create_file "app/services/#{model_name}/create_service.rb", <<~END
    class #{model_name.classify}::CreateService < ApplicationService

      def execute_service
        #{model_name} = #{klass_name}.new
        if record_save?(#{model_name})
          render_json(#{klass_name}Serializer.new(#{model_name}),{status: :created})
        else
          render_error_record(#{model_name})
        end
      end

      def record_save?(#{model_name})
        ApplicationRecord.transaction do
          update_attribute(#{model_name})
          #{model_name}.save!
        end
        return true
      rescue => e
        Rails.logger.error e.message
        Rails.logger.error e.backtrace
        return false
      end

      def update_attribute(#{model_name})
        allowed_columns = #{klass_name}::TABLE_HEADER.map(&:name)
        permitted_params = params.required(:data)
                                  .required(:attributes)
                                  .permit(allowed_columns)
        #{model_name}.attributes = permitted_params
      end
    end
    END
  end

  def update_template(model_name)
    plural_name = model_name.pluralize
    klass_name = model_name.classify
    create_file "app/services/#{model_name}/update_service.rb", <<~END
    class #{model_name.classify}::UpdateService < ApplicationService

      def execute_service
        #{model_name} = #{klass_name}.find(params[:id])
        raise RecordNotFound.new(params[:id],#{klass_name}.model_name.human) if #{model_name}.nil?
        if record_save?(#{model_name})
          render_json(#{klass_name}Serializer.new(#{model_name}))
        else
          render_error_record(#{model_name})
        end
      end

      def record_save?(#{model_name})
        ApplicationRecord.transaction do
          update_attribute(#{model_name})
          #{model_name}.save!
        end
        return true
      rescue => e
        Rails.logger.error e.message
        Rails.logger.error e.backtrace
        return false
      end

      def update_attribute(#{model_name})
        allowed_columns = #{klass_name}::TABLE_HEADER.map(&:name)
        permitted_params = params.required(:data)
                                  .required(:attributes)
                                  .permit(allowed_columns)
        #{model_name}.attributes = permitted_params
      end
    end
    END
  end


  def destroy_template(model_name)
    plural_name = model_name.pluralize
    klass_name = model_name.classify
    create_file "app/services/#{model_name}/destroy_service.rb", <<~END
    class #{model_name.classify}::DestroyService < ApplicationService

      def execute_service
        #{model_name} = #{klass_name}.find( params[:id])
        raise RecordNotFound.new(params[:id],#{klass_name}.model_name.human) if #{model_name}.nil?
        if #{model_name}.destroy
          render_json({message: "\#{#{model_name}.id} sukses dihapus"})
        else
          render_error_record(#{model_name})
        end
      end
    end
    END
  end
end
