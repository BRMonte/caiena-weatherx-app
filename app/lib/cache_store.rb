# app/lib/cache_store.rb
class CacheStore
  CACHE_DURATION = {
    coordinates: 24.hours,
    current_weather: 30.minutes,
    forecast: 2.hours,
    tweet: 2.hours
  }.freeze

  API_RATE_LIMIT_DURATION = 1.minute
  MAX_API_CALLS_PER_MINUTE = 60  # OpenWeatherMap free tier limit

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

  def self.check_api_rate_limit
    rate_key = "api_rate_limit"
    current_count = Rails.cache.read(rate_key) || 0
    
    if current_count >= MAX_API_CALLS_PER_MINUTE
      return false
    end
    
    Rails.cache.write(rate_key, current_count + 1, expires_in: API_RATE_LIMIT_DURATION)
    true
  end

  private

  def self.cache_key(city)
    "weather:#{city.downcase}"
  end
end
