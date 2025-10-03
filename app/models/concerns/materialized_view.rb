module MaterializedView
  extend ActiveSupport::Concern

  module ClassMethods
    def refresh!
      ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW CONCURRENTLY #{table_name}")
    end
  end

  included do
    def readonly?
      true
    end
  end
end
