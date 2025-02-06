module TextFormatter
  extend ActiveSupport::Concern

  included do |base_klass|
    base_klass.define_singleton_method(:ipos_fix_date_timezone) do |datetime|
      Time.zone.parse(datetime.utc.iso8601.gsub('Z',''))
    end
  end

end
