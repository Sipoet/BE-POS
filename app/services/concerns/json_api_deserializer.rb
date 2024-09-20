module JsonApiDeserializer
  extend ActiveSupport::Concern
  class TableIndex

    def initialize(params, allowed_fields, allowed_columns)
      @params = params.permit(
        :search_text,:include,:sort,
        fields: allowed_fields,
        filter: allowed_columns.map{|column| {column => filter_operators}},
        page:[:page,:limit])
      @allowed_columns = allowed_columns.map(&:to_s)
      @allowed_fields = allowed_fields.map(&:to_s)
      @param_filter = allowed_columns.present? ? @params[:filter] : params[:filter]
    end

    def deserialize
      result = Result.new
      result.search_text = @params[:search_text].to_s
      result.filters = deserialize_filters
      result.sort = deserialize_sort
      if @allowed_columns.present? & result.sort.present?
        not_allowed_column = result.sort.keys.map(&:to_s) - @allowed_columns
        not_allowed_column.each{|key| result.sort.delete(key.to_sym)}
      end
      result.page, result.limit = deserialize_pagination
      result.fields = deserialize_field
      result.included = deserialize_included & @allowed_fields
      result.query_included = deserialize_query_included
      result
    end

    def filter_operators
      [:eq,:not,:lt,:lte,:gt,:gte,:btw,:like]
    end

    private

    class Result
      attr_accessor :filters, :sort, :page, :limit,
                    :fields, :included, :search_text,
                    :query_included
    end

    def deserialize_filters
      filter = []
      return filter if @param_filter.blank?
      @param_filter.to_h.each do |key,param_value|
        if param_value.is_a?(Hash)
          param_value.each do |operator, value|
            filter << Filter.new(
              key,
              operator.to_sym,
              value
            )
          end
        else
          raise 'filter invalid pattern'
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
      included.each.with_index do |key,index|
        next unless key.include?('.')
        values = key.split('.')
        included[index] = included_nested_key(included[index],values[0],values[1..-1])
      end
      included
    end

    def included_nested_key(parent,key,values)
      if !parent.is_a?(Hash)
        parent = {}
      end
      if parent[key].nil?
        parent[key] = []
      end
      if values[2].present?
        parent[key] << included_nested_key(parent[key],values[1],values[2..-1])
      else
        parent[key] << values[1]
      end
      parent
    end

    def deserialize_field
      return nil if @params[:field].blank?
      field = {}
      @params[:field].to_h.each do |key,value|
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

    def deserialize_sort
      return nil if @params[:sort].blank?
      sorts = @params[:sort].split(',')
      sorts.each_with_object({}) do |value,obj|
        if value[0] =='-'
          obj[value[1..-1]] = :desc
        else
          obj[value] = :asc
        end
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
        if values.length == 1
          @value = values[0]
        else
          @value = values
        end
      end

      def to_query
        case @operator
        when :eq then {key => value}
        when :not then ["#{key} != ?", value]
        when :like then ["#{key} ilike ?", "%#{value}%"]
        when :gt then ["#{key} > ?", value]
        when :gte then ["#{key} >= ?", value]
        when :lt then ["#{key} < ?", value]
        when :lte then ["#{key} <= ?", value]
        when :btw then ["#{key} BETWEEN ? and ?", value[0],value[1]]
        else
          raise "filter not supported operator #{operator}"
        end
      end

      private
    end
  end

  included do

    def dezerialize_table_params(params, allowed_fields:[], allowed_columns:[])
      TableIndex.new(params, allowed_fields, allowed_columns)
                .deserialize
    end
  end
end
