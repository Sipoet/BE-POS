module Authorizer
  class ColumnAuthorizer
    attr_reader :model_names

    def self.by_role(role_id)
      cache = Cache.get("role-#{role_id}-column-auth")
      if cache.nil?
        cache = ColumnAuthorize.by_role(role_id)
        cache = cache.each_with_object({}) do |(table, columns), obj|
          obj[table] = columns.map(&:column)
        end
        Cache.set("role-#{role_id}-column-auth", cache.to_json)
      else
        cache = JSON.parse(cache)
      end
      new(role_id, cache)
    end

    def initialize(role_id, data)
      @model_names = data.keys.map(&:to_sym)
      @columns_hash = data.each_with_object({}) do |(klass_name, column_names), obj|
        obj[klass_name.to_sym] = column_names.index_by(&:to_sym)
      end
      @role_id = role_id
    end

    def superadmin?
      Role.superadmin?(@role_id)
    end

    def columns_of_klass(record_class)
      @columns_hash[record_class.to_s.to_sym]&.keys || []
    end

    def can_show?(klass:, column:)
      @columns_hash.dig(klass.to_s.to_sym, column.to_sym).present?
    end
  end
end
