class Setting < ApplicationRecord

  validates :key_name, presence: true
  validates :value, presence: true
  belongs_to :user, optional: true

  after_save :delete_cache
  after_destroy :delete_cache
  private

  def delete_cache
    if user_id.present?
      Cache.delete("setting-#{user_id}-#{key_name}")
    end
    Cache.delete("setting-#{key_name}")
  end

  def self.get(key_name, user_id: nil)
    cache_key = ['setting',key_name,user_id].compact.join('-')
    cache_data = Cache.get(cache_key)
    return JSON.parse(cache_data)['data'] if cache_data.present?
    setting =  self.find_by(key_name: key_name, user_id: user_id)
    return nil if setting.nil?
    Cache.set(cache_key,setting.value)
    return JSON.parse(setting.value)['data']
  end

end
