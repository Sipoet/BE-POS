module JsonApiDeserializer
  extend ActiveSupport::Concern
  class TableIndex
    FILTER_OPERATORS = %i[eq not lt lte gt gte btw like].freeze

    def initialize(params, allowed_fields, table_definitions)
      allowed_columns = table_definitions.column_names
      filter_keys = allowed_columns.map { |name| { name => FILTER_OPERATORS } }
      @params = params.permit(
        :search_text, :include, :sort,
        fields: allowed_fields,
        filter: filter_keys,
        page: %i[page limit]
      )
      Rails.logger.debug "filter key: #{@params[:filter]}"
      @table_definitions = table_definitions
      @allowed_columns = allowed_columns.index_by(&:to_sym)
      @allowed_fields = allowed_fields.map(&:to_s)
      @param_filter = allowed_columns.present? ? @params[:filter] : params[:filter]
    end

    def deserialize
      column_hash = @table_definitions.column_definitions.index_by(&:name)
      result = Result.new
      result.search_text = ApplicationRecord.sanitize_sql_like(@params[:search_text].to_s)
      result.filters = deserialize_filters(column_hash)
      result.sort = deserialize_sort(column_hash)
      result.page, result.limit = deserialize_pagination
      result.fields = deserialize_field
      result.included = deserialize_included & @allowed_fields
      result.query_included = deserialize_query_included
      result
    end

    private

    class Result
      attr_accessor :filters, :sort, :page, :limit,
                    :fields, :included, :search_text,
                    :query_included
    end

    def deserialize_filters(column_hash)
      filter = []
      return filter if @param_filter.blank?

      @param_filter.to_h.each do |key, param_value|
        next unless column_hash[key.to_sym].try(:can_filter)

        raise 'filter invalid pattern' unless param_value.is_a?(Hash)

        param_value.each do |operator, value|
          filter << Filter.new(
            column_hash[key.to_sym].filter_key,
            operator.to_sym,
            value
          )
        end
      end
      filter
    end

    def deserialize_included
      return [] if @params[:include].blank?

      @params[:include].split(',')
    end

    def deserialize_query_included
      return [] if @params[:include].blank?

      included = @params[:include].split(',')
      included.each.with_index do |key, index|
        next unless key.include?('.')

        values = key.split('.')
        included[index] = included_nested_key(included[index], values[0], values[1..-1])
      end
      included
    end

    def included_nested_key(parent, key, values)
      parent = {} unless parent.is_a?(Hash)
      parent[key] = [] if parent[key].nil?
      parent[key] << if values[2].present?
                       included_nested_key(parent[key], values[1], values[2..-1])
                     else
                       values[1]
                     end
      parent
    end

    def deserialize_field
      return nil if @params[:field].blank?

      field = {}
      @params[:field].to_h.each do |key, value|
        puts "======|======#{value}"
        field[key] = value.split(',')
      end
      field
    end

    def deserialize_pagination
      return [nil, nil] if @params[:page].blank?

      page = @params[:page][:page]
      limit = @params[:page][:limit]
      page = page.to_i if page.present?
      limit = limit.to_i if limit.present?
      [page, limit]
    end

    def deserialize_sort(column_hash)
      return nil if @params[:sort].blank?

      sorts = @params[:sort].split(',')
      sorts.each_with_object({}) do |value, obj|
        column_name, sort_value = nil
        if value[0] == '-'
          column_name = value[1..-1].to_sym
          sort_value = :desc
        else
          column_name = value.to_sym
          sort_value = :asc
        end
        next unless column_hash[column_name].try(:can_sort)
        next if @allowed_columns[column_name].blank?

        sort_key = column_hash[column_name].sort_key
        obj[sort_key] = sort_value
      end
    end

    class Filter
      attr_accessor :key, :operator
      attr_reader :value

      def initialize(key, op, val)
        @key = key
        @operator = op
        set_value(val)
      end

      def set_value(val)
        values = val.split(',')
        @value = if values.length == 1
                   ActiveRecord::Base.sanitize_sql(values[0])
                 else
                   values
                 end
      end

      def add_filter_to_query(query)
        case @operator
        when :eq then query.where(key => value)
        when :not then query.where.not(key => value)
        when :like then query.where(ApplicationRecord.sanitize_sql_array(["#{key} ilike ?", "%#{ApplicationRecord.sanitize_sql_like(value)}%"]))
        when :gt then query.where(ApplicationRecord.sanitize_sql_array(["#{key} > ?", value]))
        when :gte then query.where(key => value..)
        when :lt then query.where(key => ..value)
        when :lte then query.where(key => ...value)
        when :btw then query.where(key => value[0]..value[1])
        else
          raise "filter not supported operator #{operator}"
        end
      end

      def to_query
        case @operator
        when :eq then { key => value }
        when :not
          if value.is_a?(Array)
            ["#{key} not IN (?)", value]
          else
            sanitize_values = value.map { |line_value| ActiveRecord::Base.sanitize_sql(line_value) }
            ["#{key} != ?", sanitize_values]
          end
        when :like then ["#{key} ilike ?", "%#{ApplicationRecord.sanitize_sql_like(value)}%"]
        when :gt then ["#{key} > ?", value]
        when :gte then { key => value.. }
        when :lt then { key => ..value }
        when :lte then { key => ...value }
        when :btw then { key => value[0]..value[1] }
        else
          raise "filter not supported operator #{operator}"
        end
      end
    end
  end

  included do
    def dezerialize_table_params(params, allowed_fields: [], table_definitions: [])
      TableIndex.new(params, allowed_fields, table_definitions)
                .deserialize
    end
  end
end
