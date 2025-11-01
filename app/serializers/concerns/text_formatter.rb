module TextFormatter
  extend ActiveSupport::Concern

  included do |base_klass|
    base_klass.extend(ActionView::Helpers::NumberHelper)
    base_klass.define_singleton_method(:ipos_fix_date_timezone) do |datetime|
      return datetime if datetime.nil?

      Time.zone.parse(datetime.utc.iso8601.gsub('Z', ''))
    end

    base_klass.define_singleton_method(:number_format) do |value|
      number_with_delimiter(value)
    end
  end
end
