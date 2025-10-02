# app/lib/cache_store.rb
class CacheStore
  CACHE_DURATION = {
    coordinates: 24.hours,
    current_weather: 30.minutes,
    forecast: 2.hours,
    tweet: 2.hours # you can not tweets the same content twice. While the city forecast doesnt change, the tweet is fresh
  }.freeze

  def self.get(city)
    Rails.cache.read(cache_key(city))
  end

  def self.set(city, data)
    Rails.cache.write(cache_key(city), data, expires_in: 24.hours)
  end

  def self.is_fresh?(city, field)
    cached_data = get(city)
    return false unless cached_data&.dig(:cached_at, field)
    
    cached_time = Time.parse(cached_data[:cached_at][field])
    expiry_time = cached_time + CACHE_DURATION[field]
    Time.current < expiry_time
  end

  private

  def self.cache_key(city)
    "weather:#{city.downcase}"
  end
end
