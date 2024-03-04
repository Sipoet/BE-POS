class Setting < ApplicationRecord

  validates :key_name, presence: true
  validates :value, presence: true
  belongs_to :user, optional: true


  def self.get(key_name)
    cache_data = Cache.get("setting-#{key_name}")
    return JSON.parse(cache_data)['data'] if cache_data.present?
    setting =  self.find_by(key_name: key_name)
    return nil if setting.nil?
    Cache.get("setting-#{key_name}",setting.value.to_json)
    return value['data']
  end

end
