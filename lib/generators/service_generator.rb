class ServiceGenerator < Rails::Generators::NamedBase
  def create_initializer_file
    raise 'service must be filled' if args.blank?

    model_name = file_name.underscore.singularize
    args.each { |service_name| create_file_service(model_name, service_name) }
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
      default_template(model_name, service_name)
    end
  end

  def default_template(_model_name, service_name)
    klass_name = file_path.classify
    create_file "app/services/#{file_path}/#{service_name.singularize}_service.rb", <<~END
      class #{klass_name}::#{service_name.classify}Service < ApplicationService

        def execute_service
          # insert code here
        end

      end
    END
  end

  def index_template(model_name)
    plural_name = file_name.underscore.pluralize
    klass_name = file_path.classify
    create_file "app/services/#{file_path}/index_service.rb", <<~END
      class #{klass_name}::IndexService < ApplicationService

        include JsonApiDeserializer
        def execute_service
          extract_params
          @#{plural_name} = find_#{plural_name}
          options = {
            meta: meta,
            fields: @fields,
            params:{include: @included},
            include: @included
          }
          render_json(#{klass_name}Serializer.new(@#{plural_name},options))
        end

        def meta
          {
            page: @page,
            limit: @limit,
            total_rows: @#{plural_name}.total_count,
             total_pages: @#{plural_name}.total_pages,
          }
        end

        def extract_params
          @table_definitions = Datatable::DefinitionExtractor.new(#{klass_name})
          allowed_fields = [:#{model_name}]
          result = dezerialize_table_params(params,
            allowed_fields: allowed_fields,
            table_definitions: @table_definitions)
          @page = result.page || 1
          @limit = result.limit || 20
          @search_text = result.search_text
          @sort = result.sort
          @included = result.included
          @query_included = result.query_included
          @filters = result.filters
          @fields = result.fields
        end

        def find_#{plural_name}
          #{plural_name} = #{klass_name}.all.includes(@query_included)
            .page(@page)
            .per(@limit)
          if @search_text.present?
            #{plural_name} = #{plural_name}.where(['name ilike ? ']+ Array.new(1,"%\#{@search_text}%"))
          end
          @filters.each do |filter|
            #{plural_name} = filter.add_filter_to_query(#{plural_name})
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
    file_name.underscore.pluralize
    klass_name = file_path.classify
    create_file "app/services/#{file_path}/show_service.rb", <<~END
      class #{klass_name}::ShowService < ApplicationService

        include JsonApiDeserializer
        def execute_service
          extract_params
          #{model_name} = #{klass_name}.find(params[:id])
          raise RecordNotFound.new(params[:id],#{klass_name}.model_name.human) if #{model_name}.nil?
          options = {
            fields: @fields,
            params:{include: @included},
            include: @included
          }
          render_json(#{klass_name}Serializer.new(#{model_name},options))
        end

        def extract_params
          @table_definitions = Datatable::DefinitionExtractor.new(#{klass_name})
          allowed_fields = [:#{model_name}]
          result = dezerialize_table_params(params,
            allowed_fields: allowed_fields,
            table_definitions: @table_definitions)
          @included = result.included
          @fields = result.fields
        end

      end
    END
  end

  def create_template(model_name)
    file_name.underscore.pluralize
    klass_name = file_path.classify
    create_file "app/services/#{file_path}/create_service.rb", <<~END
      class #{klass_name}::CreateService < ApplicationService

        def execute_service
          #{model_name} = #{klass_name}.new
          if record_save?(#{model_name})
            render_json(#{klass_name}Serializer.new(#{model_name},fields:@fields),{status: :created})
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
          @table_definitions = Datatable::DefinitionExtractor.new(#{klass_name})
          @fields = {#{model_name}: @table_definitions.allowed_columns}
          permitted_columns = permitted_column_names(#{klass_name},@table_definitions.allowed_edit_columns)
          permitted_params = params.required(:data)
                                    .required(:attributes)
                                    .permit(permitted_columns)
          #{model_name}.attributes = permitted_params
        end
      end
    END
  end

  def update_template(model_name)
    file_name.underscore.pluralize
    klass_name = file_path.classify
    create_file "app/services/#{file_path}/update_service.rb", <<~END
      class #{klass_name}::UpdateService < ApplicationService

        def execute_service
          #{model_name} = #{klass_name}.find(params[:id])
          raise RecordNotFound.new(params[:id],#{klass_name}.model_name.human) if #{model_name}.nil?
          if record_save?(#{model_name})
            render_json(#{klass_name}Serializer.new(#{model_name},{fields: @fields}))
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
          @table_definitions = Datatable::DefinitionExtractor.new(#{klass_name})
          @fields = {#{model_name}: @table_definitions.allowed_columns}
          permitted_columns = permitted_column_names(#{klass_name},@table_definitions.allowed_edit_columns)
          permitted_params = params.required(:data)
                                    .required(:attributes)
                                    .permit(permitted_columns)
          #{model_name}.attributes = permitted_params
        end
      end
    END
  end

  def destroy_template(model_name)
    file_name.underscore.pluralize
    klass_name = file_path.classify
    create_file "app/services/#{file_path}/destroy_service.rb", <<~END
      class #{klass_name}::DestroyService < ApplicationService

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
